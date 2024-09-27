//
//  MapManager.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/16/24.
//

import CoreLocation
import Foundation
import MapKit

import MapboxNavigationCore
import MapboxDirections

// TODO: Update public methods from Mapbox params to MapKit params
class MapManager: ObservableObject {
    
    @Published private(set) var isInActiveNavigation: Bool = false
    @Published private(set) var currentPreviewRoutes: NavigationRoutes?
    @Published private(set) var currentLocation: CLLocation?
    @Published var profileIdentifier: ProfileIdentifier = .automobileAvoidingTraffic
    
    private var waypoints: [Waypoint] = []
    private var core: MapboxNavigation? = nil
    
    // Route Data
    @Published var route: Route?
    @Published var legPolylines: [MKPolyline]?
    
    // Route getters
    // TODO: Add getters for start end coords of each leg
    func getStartCoordinate() -> CLLocationCoordinate2D? {
        return self.route?.shape?.coordinates.first
    }
    func getEndCoordinate() -> CLLocationCoordinate2D? {
        return self.route?.shape?.coordinates.last
    }

    
    func setupMapbox() async {
        let config = CoreConfig(credentials: .init())
        let navigatorProvider = MapboxNavigationProvider(coreConfig: config)
        self.core = await navigatorProvider.mapboxNavigation
    }
    
    // Directions
    func getDirections() {
        
        // Check if there is a selected result
        guard let previewRoutes = currentPreviewRoutes else { return }
        let mainRoute = previewRoutes.mainRoute.route
                            
        self.route = route
        self.legPolylines = getPolylines(route: mainRoute)

        // Get directions from selected route
        
        // Create and configure the request
        //        let request = MKDirections.Request()
        //        request.source = MKMapItem(placemark: source)
        //        request.destination = MKMapItem(placemark: destination)
        //        // Get the directions based on the request
        //        Task {
        //            let directions = MKDirections(request: request)
        //            let response = try? await directions.calculate()
        //            route = response?.routes.first
        //
        //        }
    }
    
    // Routing
    
    // Generate MKRoute from Mapbox Route
    /*
    private func getMKRoute(route: Route) -> MKRoute {
        let mkRoute = MKRoute()
        
        var coordinates = [CLLocationCoordinate2D]()
        if let routeShape = route.shape {
            coordinates = routeShape.coordinates
        } else { return mkRoute }
        
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mkRoute.setValue(polyline, forKey: "polyline")
        mkRoute.setValue(route.distance, forKey: "distance")
        mkRoute.setValue(route.expectedTravelTime, forKey: "expectedTravelTime")
        
        
        var steps = [MKRoute.Step]()
        for leg in route.legs {
            for step in leg.steps {
                let mkRouteStep = MKRoute.Step()
                mkRouteStep.setValue(step.instructions, forKey: "instructions")
                mkRouteStep.setValue(step.distance, forKey: "distance")
                mkRouteStep.setValue(step.expectedTravelTime, forKey: "expectedTravelTime")
                
                let stepPolyline = MKPolyline(
                    coordinates: step.shape?.coordinates ?? [],
                    count: step.shape?.coordinates.count ?? 0)
                mkRouteStep.setValue(stepPolyline, forKey: "polyline")
                
                steps.append(mkRouteStep)
            }
        }
        mkRoute.setValue(steps, forKey: "steps")
        
        return mkRoute
    }
    */
    
    // Take a mapbox Route and convert to polylines, each polyline being a leg of the route
    private func getPolylines(route: Route) -> [MKPolyline] {
        var legs = [MKPolyline]()
        
        for leg in route.legs {
            var stepCoordinates = [CLLocationCoordinate2D]()
            for step in leg.steps {
//                let startCoordinate = step.shape?.coordinates.first
//                let endCoordinate = step.shape?.coordinates.last
                
                if let coordinates = step.shape?.coordinates {
                    stepCoordinates += coordinates
                }
            }
            legs.append(MKPolyline(coordinates: stepCoordinates, count: stepCoordinates.count))
        }
        
        return legs
    }
    
    // Add waypoint to route
    func addWaypoint(to coords: CLLocationCoordinate2D) async throws {
        let mapPoint = toMapPoint(coordinates: coords)
        waypoints.append(Waypoint(coordinate: mapPoint.coordinate, name: mapPoint.name))
        if waypoints.count > 1 {
            try await updateRoutes()
        }
    }
    
    // Add current location as waypoint to route
    func addCurrentLocationWaypoint(currentLocation: CLLocation, isFirst: Bool) async throws {
        var userWaypoint = Waypoint(location: currentLocation)
        if currentLocation.course >= 0 {
            userWaypoint.heading = currentLocation.course
            userWaypoint.headingAccuracy = 90
        }
        if isFirst {
            waypoints.insert(userWaypoint, at: 0)
        } else {
            waypoints.append(userWaypoint)
        }
    }
    
    // Remove waypoint on route
    func removeWayPoint(waypoint: Waypoint) async throws {
        if let index = waypoints.firstIndex(of: waypoint) {
            waypoints.remove(at: index)
        }
        try await updateRoutes()
    }
    
    // Convert CLLocationCoordinate2D to MapPoint
    // TODO: Update MapPoint name
    private func toMapPoint(coordinates: CLLocationCoordinate2D) -> MapPoint {
        return MapPoint(name: "", coordinate: coordinates)
    }
    
    // Update generated route based on changes to waypoints
    private func updateRoutes() async throws {
        if let provider = await core?.routingProvider() {
            let routeOptions = NavigationRouteOptions(
                waypoints: waypoints,
                profileIdentifier: profileIdentifier
            )
            
            
            switch await provider.calculateRoutes(options: routeOptions).result {
            case .success(let previewRoutes):
                currentPreviewRoutes = previewRoutes
            case.failure(let e):
                print(e)
            }
            
            // Create MKRoute for each leg
            //
            
            let previewRoutes = try await provider.calculateRoutes(options: routeOptions).value
//            
            currentPreviewRoutes = previewRoutes
        }
    }
    
    // Make an alternative route the main route
    func selectAlternativeRoute(_ alternativeRoute: AlternativeRoute) async {
        if let previewRoutes = currentPreviewRoutes {
            currentPreviewRoutes = await previewRoutes.selecting(alternativeRoute: alternativeRoute)
        }
    }
    
    
}

