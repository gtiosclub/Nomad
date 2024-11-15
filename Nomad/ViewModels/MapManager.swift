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
        print("Failed to find user's location: \(error.localizedDescription)")
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
    
    //    // Add waypoint to route
    //    func addWaypoint(to coords: CLLocationCoordinate2D) async throws {
    //        let mapPoint = toMapPoint(coordinates: coords)
    //        waypoints.append(Waypoint(coordinate: mapPoint.coordinate, name: mapPoint.name))
    //        if waypoints.count > 1 {
    //            try await updateRoutes()
    //        }
    //
    //    }
    //    // Add current location as waypoint to route
    //    func addCurrentLocationWaypoint(currentLocation: CLLocation, isFirst: Bool) async throws {
    //        var userWaypoint = Waypoint(location: currentLocation)
    //        if currentLocation.course >= 0 {
    //            userWaypoint.heading = currentLocation.course
    //            userWaypoint.headingAccuracy = 90
    //        }
    //        if isFirst {
    //            waypoints.insert(userWaypoint, at: 0)
    //        } else {
    //            waypoints.append(userWaypoint)
    //        }
    //    }
    //    func modifyWaypointsOrdering(newWaypoints: [Waypoint]) async throws {
    //        waypoints = newWaypoints
    //        if waypoints.count > 1 {
    //            try await updateRoutes()
    //        }
    //    }
    //    // Remove waypoint on route
    //    func removeWayPoint(waypoint: Waypoint) async throws {
    //        if let index = waypoints.firstIndex(of: waypoint) {
    //            waypoints.remove(at: index)
    //        }
    //        try await updateRoutes()
    //    }
    // TODO: Update MapPoint name
    private func toMapPoint(coordinates: CLLocationCoordinate2D) -> MapPoint {
        return MapPoint(name: "", coordinate: coordinates)
    }
    
    // Route progress functions
    //    func getFutureLocation(time: TimeInterval) async throws -> CLLocationCoordinate2D {
    //        var routeProgress: RouteProgress
    //
    //        if let rp = await self.core?.navigation().currentRouteProgress?.routeProgress {
    //            routeProgress = rp
    //            if routeProgress.durationRemaining <= time {
    //                return self.mapMarkers.last?.coordinate ?? CLLocationCoordinate2D()
    //            }
    //        } else { // Creating a RouteProgress if this function called for a route that hasn't been started
    //            getDirections()
    //            if let currRoutes = self.currentPreviewRoutes {
    //                routeProgress = RouteProgress(navigationRoutes: currRoutes, waypoints: self.waypoints)
    //                // A newly-generated RouteProgress has no expected travel time in it
    //                if currRoutes.mainRoute.route.expectedTravelTime <= time {
    //                    return self.mapMarkers.last?.coordinate ?? CLLocationCoordinate2D()
    //                }
    //            } else {
    //                throw("Cannot get future location with no routes")
    //            }
    //        }
    //
    //        var currTime = 0.0
    //        var currStep = routeProgress.currentLegProgress.currentStep
    //        var remainingSteps = routeProgress.currentLegProgress.remainingSteps
    //        var remainingLegs = routeProgress.remainingLegs
    //
    //        while currTime < time {
    //            if remainingSteps.isEmpty && !remainingLegs.isEmpty {
    //                let newLeg = remainingLegs.removeFirst()
    //                remainingSteps = newLeg.steps
    //            }
    //
    //            currStep = remainingSteps.removeFirst()
    //            currTime += currStep.typicalTravelTime ?? currStep.expectedTravelTime
    //        }
    //
    //        return currStep.shape?.coordinates.last ?? CLLocationCoordinate2D()
    //    }
    
    func getFutureLocation(time: TimeInterval, route: NomadRoute) -> CLLocationCoordinate2D? {
        
        var currTime = 0.0
        
        for leg in route.legs {
            for step in leg.steps {
                if currTime < time {
                    currTime += step.direction.expectedTravelTime
                } else {
                    return step.endCoordinate
                }
                
            }
        }
        return nil
    }
    
    func determineCurrentStep(leg: NomadLeg) -> NomadStep? {
        for step in leg.steps {
            if checkOnRoute(step: step) {
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
        return closestCoordinate ?? CLLocationCoordinate2D()
    }
    func checkOnRoute(step: NomadStep) -> Bool {
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
        let endCoord = leg.endCoordinate
        let measured_distance = userLocation.distance(to: endCoord)
        let thresholdDistance: CLLocationDistance = 100
        if measured_distance <= thresholdDistance {
            return true
        }
        return false
    }
 
    func getExampleRoute() async -> NomadRoute? {
        let trip = UserViewModel.my_trips.first!
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
