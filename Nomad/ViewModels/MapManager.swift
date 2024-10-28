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
        if let location = locations.last {
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.5)) {
                    self.userLocation = location.coordinate // Update user location
                    self.motion.coordinate = location.coordinate
                    self.motion.altitude = location.altitude
                    self.motion.speed = location.speed
                    self.motion.direction = location.course
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
    
    
    func checkIfOffPath(currentLocation: CLLocation) -> Bool {
        let routeCoordinates = currentStep.getCoordinates()
        let thresholdDistance: CLLocationDistance = 50
        
        var closestDistance = CLLocationDistanceMax
        var closestCoordinate: CLLocationCoordinate2D?
        
        for coord in routeCoordinates {
            let routeLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            let distance = currentLocation.distance(from: routeLocation)
            
            if distance < closestDistance {
                closestDistance = distance
                closestCoordinate = coord
            }
        }
        
        if closestDistance > thresholdDistance {
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
}
