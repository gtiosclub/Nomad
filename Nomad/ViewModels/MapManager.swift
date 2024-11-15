//
//  MapManager.swift
//  Nomad
//  SINGLETON CLASS
//  Created by Nicholas Candello on 9/16/24.
//

import CoreLocation
import Foundation
import MapKit
import SwiftUI

import MapboxNavigationCore
import MapboxDirections
import FirebaseFirestore

// TODO: Update public methods from Mapbox params to MapKit params
class MapManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let manager = MapManager()
    
    // Map State/Settings
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var motion = Motion()
    
    // Route Data
    
    private override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    /// LOCATION MANAGER FUNCTIONS
    private var locationManager = CLLocationManager()
    // Continuously update user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLoc = locations.last {
            DispatchQueue.main.async {
                let MIN_DIST_TO_UPDATE = 50.0 // in m
                let MIN_SPEED_TO_UPDATE = 1.5 // in m/s
                let speed = newLoc.speed
                let distance = self.userLocation?.distance(to: LocationCoordinate2D(latitude: newLoc.coordinate.latitude, longitude: newLoc.coordinate.longitude)) ?? 40000000
                if speed >= MIN_SPEED_TO_UPDATE || distance >= MIN_DIST_TO_UPDATE {
                    
                    withAnimation(.easeInOut(duration: 0.5)) {
                        self.userLocation = newLoc.coordinate // Update user location
                        self.motion.coordinate = newLoc.coordinate
                        self.motion.altitude = newLoc.altitude
                        self.motion.speed = newLoc.speed
                        self.motion.direction = newLoc.course
                    }
                }
            }
        }
    }
    // Handle location access errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // Route getters
    // TODO: Add getters for start end coords of each leg
    
    // MAPBOX FUNCTIONS
    func setupMapbox() async {
        if self.core == nil {
            let config = CoreConfig(credentials: .init())
            let navigatorProvider = MapboxNavigationProvider(coreConfig: config)
            self.core = await navigatorProvider.mapboxNavigation
            print("mapbox setup")
        }
    }
    
    /// ROUTE GENERATION FUNCTIONS
    private var profileIdentifier: ProfileIdentifier = .automobileAvoidingTraffic
    
    public func generateRoute(pois: [any POI]) async -> [NomadRoute]? {
        let coords = pois.map { poi in
            CLLocationCoordinate2D(latitude: poi.latitude, longitude: poi.longitude)
        }
        return await generateRoute(stop_coords: coords)
    }
    // generate routes for navigation (index 0 is main route, others are alternates)
    public func generateRoute(stop_coords: [CLLocationCoordinate2D]) async -> [NomadRoute]? {
        // print("fetching routes...")
        var nomadRoutes = [NomadRoute]() // return variable
        var tripWaypoints: [Waypoint] = []
        for coord in stop_coords {
            let mapPoint = toMapPoint(coordinates: coord)
            tripWaypoints.append(Waypoint(coordinate: mapPoint.coordinate, name: mapPoint.name))
        }
        
        var navRoutes: NavigationRoutes?
        if let provider = await core?.routingProvider() {
            let routeOptions = NavigationRouteOptions(
                waypoints: tripWaypoints,
                profileIdentifier: profileIdentifier
            )
            
            switch await provider.calculateRoutes(options: routeOptions).result {
            case .success(let previewRoutes):
                navRoutes = previewRoutes
            case.failure(let e):
                print(e)
            }
            
            // Create MKRoute for each leg
            // inefficient API calls (combine these two sections
            
            do {
                let previewRoutes = try await provider.calculateRoutes(options: routeOptions).value
                navRoutes = previewRoutes
            } catch {
                print(error.localizedDescription)
            }
            
            // Check if there is a selected result'
            guard let previewRoutes = navRoutes else { return nil }
            let mainRoute = previewRoutes.mainRoute.route
            
            let mainRouteLegs = getLegs(route: mainRoute)
            let mainNomadRoute = NomadRoute(route: mainRoute, legs: mainRouteLegs)
            
            nomadRoutes.append(mainNomadRoute)
            
            let alternativeRoutes = previewRoutes.alternativeRoutes
            for alt_route in alternativeRoutes {
                let route = alt_route.route
                
                let routeLegs = getLegs(route: mainRoute)
                let nomadRoute = NomadRoute(route: mainRoute, legs: routeLegs)
                
                nomadRoutes.append(nomadRoute)
            }
            // print("...routes fetched")
            return nomadRoutes
            
        } else {
            print("error: no routing provider")
        }
        return nil
    }
    
    // regenerate route from saved coordinates
    public func generateRoute(coords: [[CLLocationCoordinate2D]], expectedTravelTime: TimeInterval, distance: CLLocationDistance) async -> NomadRoute? {
        var legs = [NomadLeg]()
        var mapboxLegs = [MapboxDirections.RouteLeg]()
        
        if let provider = await core?.routingProvider() {
            for legCoords in coords {
                let options = MatchOptions(coordinates: legCoords)
                options.includesSteps = true
                
                switch await provider.calculateRoutes(options: options).result {
                        case .failure(let error):
                            print("Could not generate route from coordinates: \(error)")
                        case .success(let response):
                            if let leg = response.mainRoute.route.legs.first {
                                legs.append(NomadLeg(leg: leg))
                                mapboxLegs.append(leg)
                            }
                    }
            }
        }
        
        print("generateRoute \(legs)")
        
        // TODO: Put distance and expectedTravelTime in firestore
        let mapboxRoute = Route.init(legs: mapboxLegs, shape: nil, distance: distance, expectedTravelTime: expectedTravelTime)
        return NomadRoute(route: mapboxRoute, legs: legs)
    }
    
    public func docsToNomadRoute(docs: [QueryDocumentSnapshot]) async throws -> [String: NomadRoute] {
        var routesmap: [String: NomadRoute] = [:]
        for doc in docs {
            // Decode json
            let data = doc.data()
            var routeCoords: [[CLLocationCoordinate2D]] = [[CLLocationCoordinate2D]]()
            
            let expectedTravelTime = data["expectedTravelTime"] as? TimeInterval ?? 0.0
            let distance  = data["distance"] as? CLLocationDistance ?? 0.0
            
            for (id, legData) in data {
                if id == "expectedTravelTime" || id == "distance" { continue }
                if let legCoords = legData as? String {
                    let legCoordsList = legCoords.split(separator: ";")
                    routeCoords.append(legCoordsList.map { coord in
                        let values = String(coord).split(separator: ",")
                        return CLLocationCoordinate2D(latitude: Double(values[0]) ?? 0.0, longitude: Double(values[1]) ?? 0.0)
                    })
                }
            }            
            let route = await generateRoute(coords: routeCoords, expectedTravelTime: expectedTravelTime, distance: distance)
            routesmap[doc.documentID] = route
        }
        return routesmap
    }
    
    // ROUTE GENERATION HELPERS
    // Generate legs with Step structs
    private func getLegs(route: Route) -> [NomadLeg] {
        var legs = [NomadLeg]()
        for routeleg in route.legs {
            legs.append(NomadLeg(leg: routeleg))
        }
        return legs
    }
    
    private func getSteps(route: Route) -> [NomadStep] {
        var steps = [NomadStep]()
        for leg in route.legs {
            for step in leg.steps {
                steps.append(NomadStep(step: step))
            }
        }
        return steps
    }
    
    private func parseCoordinateString(coordString: String) -> CLLocationCoordinate2D {
        let coords = coordString.split(separator: ",")
        return CLLocationCoordinate2D(latitude: Double(coords[0]) ?? 0.0, longitude: Double(coords[1]) ?? 0.0)
    }
    
    /// WAYPOINT CRUD SECTION
    private var waypoints: [Waypoint] = []
    private var core: MapboxNavigation? = nil
    
    // TODO: Update MapPoint name
    private func toMapPoint(coordinates: CLLocationCoordinate2D) -> MapPoint {
        return MapPoint(name: "", coordinate: coordinates)
    }
    
    // New method to find closest leg
    func determineCurrentLeg(route: NomadRoute) -> NomadLeg? {
        var closestLeg: NomadLeg?
        var minDistance = CLLocationDistanceMax
        
        for leg in route.legs {
            var step: NomadStep
            if let currentStep = determineCurrentStep(leg: leg) {
                step = currentStep
            } else {
                step = leg.steps.first!
            }
                let closestCoord = getClosestCoordinate(step: step)
                if let userLocation = self.userLocation {
                    let distance = userLocation.distance(to: closestCoord)
                    if distance < minDistance {
                        minDistance = distance
                        closestLeg = leg
                    }
                }
        }
        
        return closestLeg ?? route.legs.first
    }
    
    struct RouteAdditions {
        let timeAdded: TimeInterval // in s
        let distanceAdded: Double // in m
    }
    // determine time and distance added to a route given a new stop
    func determineRouteAdditions(route: NomadRoute, newStop: CLLocationCoordinate2D) async -> RouteAdditions? {
        let updatedStops = addStopToRoute(route: route, new_coord: newStop)
        
        if let newRoutes = await generateRoute(stop_coords: updatedStops) {
            let newRoute = newRoutes.first!
            let timeAdded = newRoute.totalTime() - route.totalTime()
            let distanceAdded = newRoute.totalDistance() - route.totalDistance()
            return RouteAdditions(timeAdded: timeAdded, distanceAdded: distanceAdded)
        }
        return nil
    }
    
    // append stop to route at right location/order
    func addStopToRoute(route: NomadRoute, new_coord: CLLocationCoordinate2D) -> [CLLocationCoordinate2D] {
        var stop_coords = [CLLocationCoordinate2D]()
        for leg in route.legs {
            stop_coords.append(leg.getStartLocation())
        }
        stop_coords.append(route.legs.last!.getEndLocation())
        
        var distances = [Double]()
        for i in 0..<stop_coords.count {
            distances.append(stop_coords[i].distance(to: new_coord))
            
        }
        if let minIndex = distances.enumerated().min(by: { $0.1 < $1.1 })?.offset {
                // Insert new coordinate after the closest stop
                // If it's the last stop, append to end
                let insertIndex = minIndex == stop_coords.count - 1 ? stop_coords.count : minIndex + 1
                stop_coords.insert(new_coord, at: insertIndex)
            }
            
        return stop_coords
    }

    // Modified getFutureLocation
    func getFutureLocation(time: TimeInterval, route: NomadRoute) -> CLLocationCoordinate2D? {
        // Find current leg and step
        let currentLeg = determineCurrentLeg(route: route)
        let currentStep = currentLeg.flatMap { determineCurrentStep(leg: $0) }
        
        // Get current position on route
        let currentPosition = currentStep.flatMap { getClosestCoordinate(step: $0) }
        
        // Get all coordinates from the route
        let allCoordinates = route.getCoordinates()
        
        // Find the index where we start from (closest to current position)
        let startIndex = currentPosition.flatMap { coord in
            allCoordinates.firstIndex { $0.latitude == coord.latitude && $0.longitude == coord.longitude }
        }
        
        var accumulatedTime: TimeInterval = 0.0
        var lastCoordinate = startIndex.flatMap { allCoordinates[$0] }
        
        // Calculate average speed across the remaining route
        var totalDistance: CLLocationDistance = 0.0
        var totalTime: TimeInterval = 0.0
        
        // Only count remaining legs/steps
        var foundCurrentLeg = false
        for leg in route.legs {
            if let currentLeg = currentLeg, leg.id == currentLeg.id {
                foundCurrentLeg = true
            }
            if foundCurrentLeg {
                for step in leg.steps {
                    totalDistance += step.direction.distance
                    totalTime += step.direction.expectedTravelTime
                }
            }
        }
        
        let averageSpeed = totalDistance / totalTime // meters per second
        
        // Iterate through remaining coordinates
        for i in (startIndex ?? 0)+1..<allCoordinates.count {
            let coord = allCoordinates[i]
            let prevCoord = allCoordinates[i-1]
            
            // Calculate time to travel between these coordinates
            let segmentDistance = prevCoord.distance(to: coord)
            let segmentTime = segmentDistance / averageSpeed
            
            accumulatedTime += segmentTime
            
            if accumulatedTime >= time {
                // Interpolate between previous and current coordinate
                let overshootRatio = (accumulatedTime - time) / segmentTime
                let lat = coord.latitude + (prevCoord.latitude - coord.latitude) * overshootRatio
                let lon = coord.longitude + (prevCoord.longitude - coord.longitude) * overshootRatio
                
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            
            lastCoordinate = coord
        }
        
        return lastCoordinate
    }

    // Modified getFutureLocationByDistance
    func getFutureLocationByDistance(distance: CLLocationDistance, route: NomadRoute) -> CLLocationCoordinate2D? {
        // Find current leg and step
        let currentLeg = determineCurrentLeg(route: route)
        let currentStep = currentLeg.flatMap { determineCurrentStep(leg: $0) }
        
        // Get current position on route
        let currentPosition = currentStep.flatMap { getClosestCoordinate(step: $0) }
        
        // Get all coordinates from the route
        let allCoordinates = route.getCoordinates()
        
        // Find the index where we start from (closest to current position)
        let startIndex = currentPosition.flatMap { coord in
            allCoordinates.firstIndex { $0.latitude == coord.latitude && $0.longitude == coord.longitude }
        }
        
        var accumulatedDistance: CLLocationDistance = 0.0
        var lastCoordinate = startIndex.flatMap { allCoordinates[$0] }
        
        // Iterate through remaining coordinates
        for i in (startIndex ?? 0)+1..<allCoordinates.count {
            let coord = allCoordinates[i]
            let prevCoord = allCoordinates[i-1]
            
            let segmentDistance = prevCoord.distance(to: coord)
            accumulatedDistance += segmentDistance
            
            if accumulatedDistance >= distance {
                // Interpolate between previous and current coordinate
                let overshootDistance = accumulatedDistance - distance
                let ratio = 1 - (overshootDistance / segmentDistance)
                
                // Linear interpolation between coordinates
                let lat = prevCoord.latitude + (coord.latitude - prevCoord.latitude) * ratio
                let lon = prevCoord.longitude + (coord.longitude - prevCoord.longitude) * ratio
                
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            
            lastCoordinate = coord
        }
        
        return lastCoordinate
    }
    
    // get remaining time on current leg at current user location
    func getRemainingTime(leg: NomadLeg) -> TimeInterval {
        var totalTime: TimeInterval = 0
        
        var step: NomadStep
        if let currentStep = determineCurrentStep(leg: leg) {
            step = currentStep
        } else {
            step = leg.steps.first!
        }
        let step_index = leg.steps.firstIndex { $0.id == step.id }!
        // append time for all future steps
        for i in step_index+1..<leg.steps.count {
            totalTime += TimeInterval(leg.steps[i].direction.expectedTravelTime)
        }
        let coord = getClosestCoordinate(step: step)
        let coord_index = step.getCoordinates().firstIndex(where: { $0 == coord })!
        let total_coord_count = step.getCoordinates().count
        let distance = (Double(total_coord_count - coord_index)/Double(total_coord_count)) * step.direction.distance
        let stepProgress = distance / step.direction.distance
        totalTime += stepProgress * TimeInterval(step.direction.expectedTravelTime)
        
        // print("total time remaining on leg: \(totalTime.description)")
        return totalTime
    }
    
    // get remaining distance on current leg
    func getRemainingDistance(leg: NomadLeg) -> TimeInterval {
        var totalDistance: TimeInterval = 0
        
        var step: NomadStep
        if let currentStep = determineCurrentStep(leg: leg) {
            step = currentStep
        } else {
            step = leg.steps.first!
        }
        
        let step_index = leg.steps.firstIndex { $0.id == step.id }!
        // append time for all future steps
        for i in step_index+1..<leg.steps.count {
            totalDistance += leg.steps[i].direction.distance
        }
        let coord = getClosestCoordinate(step: step)
        let coord_index = step.getCoordinates().firstIndex(where: { $0 == coord })!
        let total_coord_count = step.getCoordinates().count
        let distance = (Double(total_coord_count - coord_index)/Double(total_coord_count)) * step.direction.distance
        totalDistance += distance
        
        return totalDistance
    }
    
    func determineCurrentStep(leg: NomadLeg) -> NomadStep? {
            for step in leg.steps {
                if checkOnRouteDistance(step: step, thresholdDistance: 80) {
                    return step
                }
            }
            return nil
        }
        
    func getClosestCoordinate(step: NomadStep) -> CLLocationCoordinate2D {
        guard let userLocation = self.userLocation else { return CLLocationCoordinate2D() }
        let stepCoordinates = step.getCoordinates()
        
        var closestDistance = CLLocationDistanceMax
        var closestCoordinate: CLLocationCoordinate2D?
        
        for coord in stepCoordinates {
            let distance = userLocation.distance(to: coord)
            
            if distance < closestDistance {
                closestDistance = distance
                closestCoordinate = coord
            }
        }
        return closestCoordinate ?? step.startCoordinate
    }
    
    func checkOnStep(step: NomadStep) -> Bool {
        guard let userLocation = self.userLocation else { return false }
        let closest_coord = getClosestCoordinate(step: step)
        let measured_distance = userLocation.distance(to: closest_coord)
        let thresholdDistance: CLLocationDistance = 50  // maximum allowed distance from route (in m)
        if measured_distance <= thresholdDistance {
            return true
        } else {
            return false
        }
    }
    
    func checkDestinationReached(leg: NomadLeg) -> Bool {
        guard let userLocation = self.userLocation else { return false }
        guard let speed = motion.speed else { return false }
        let endCoord = leg.endCoordinate
        let measured_distance = userLocation.distance(to: endCoord)
        let thresholdDistance: CLLocationDistance = 150
        let thresholdSpeed: CLLocationSpeed = 3.5
        // print(measured_distance)
        // print(speed)
        if measured_distance <= thresholdDistance && speed <= thresholdSpeed {
            return true
        }
        return false
    }
    func checkOnRouteDirection(step: NomadStep, thresholdDirection: Double) -> Bool {
        guard let userLocation = self.userLocation else { return false }
        let coords = step.getCoordinates()
        
        let closestCoord = getClosestCoordinate(step: step)
        let nextCoordIndex = Int(coords.firstIndex(of: closestCoord) ?? coords.endIndex) + 1
        
        // Uses closest coord & next coord in route to find expected direction, if not use curr coordinate & closest
        let expectedDirection: CLLocationDirection
        if let nextClosestCoord = coords.dropFirst(nextCoordIndex).first {
            expectedDirection = calculateHeading(from: closestCoord, to: nextClosestCoord)
        } else {
            expectedDirection = calculateHeading(from: motion.coordinate!, to: closestCoord)
        }

        return abs(expectedDirection - motion.direction!) < thresholdDirection
    }
    
    func checkOnRouteDistance(step: NomadStep, thresholdDistance: CLLocationDistance) -> Bool {
            guard let userLocation = self.userLocation else { return false }
            let closest_coord = getClosestCoordinate(step: step)
            let measured_distance = userLocation.distance(to: closest_coord)
            if measured_distance <= thresholdDistance {
                return true
            } else {
                return false
            }
        }
    
    // Helper function to calculate heading between two coordinates
    func calculateHeading(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDirection {
        let deltaL = to.longitude * (.pi / 180.0)  - from.longitude * (.pi / 180.0)
        let thetaB = from.latitude * (.pi / 180.0)
        let thetaA = to.latitude * (.pi / 180.0)
        let x = cos(thetaB) * sin(deltaL)
        let y = cos(thetaA) * sin(thetaB) - sin(thetaA) * cos(thetaB) * cos(deltaL)

        let bearingDeg = atan2(x, y) * (180.0 / .pi)
        return bearingDeg < 0 ? 360 + bearingDeg : bearingDeg // CLLocationDirection takes 0-360
    }
 
    func getExampleRoute() async -> NomadRoute? {
        let trip = Trip(id: "austintrip2", start_location: Restaurant(address: "848 Spring Street, Atlanta, GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN 37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", created_date: "10-1-2024", modified_date: "10-1-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], start_time: "10:00:00", name: "ATL to Nashville", isPrivate: true)
        var coords = [CLLocationCoordinate2D]()
        let start_coord = self.userLocation ?? trip.getStartLocationCoordinates()
        coords.append(start_coord)
        coords.append(trip.getEndLocationCoordinates())
        for stop in trip.getStops() {
            coords.append(CLLocationCoordinate2D(latitude: stop.getLatitude(), longitude: stop.getLongitude()))
        }
        if let route = await MapManager.manager.generateRoute(stop_coords: coords) {
            return route.first
        } else {
            return nil
        }
    }
    // TODO: Convert to JSON
    func encode(to encoder: Encoder) throws {
        
    }
}
