//
//  MapManager.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/16/24.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI

import MapboxNavigationCore
import MapboxDirections

class MapManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    
    // Route Data
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var route: MKRoute? = nil
    @Published var source = MKPlacemark(coordinate: CLLocationCoordinate2D())
    @Published var destination =  MKPlacemark(coordinate: CLLocationCoordinate2D())
    @Published var motion = Motion()
    @Published var region = MKCoordinateRegion()
    
    // Map State/Settings
    @Published var mapPosition: MapCameraPosition = .userLocation(fallback: .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: .zero, longitude: .zero), distance: 0)))
    @Published var bearing: Double = 0.0
    @Published var mapType: MapTypes = .defaultMap
    
    @Published private(set) var isInActiveNavigation: Bool = false
    @Published private(set) var currentPreviewRoutes: NavigationRoutes?
    @Published private(set) var currentLocation: CLLocation?
    @Published var profileIdentifier: ProfileIdentifier = .automobileAvoidingTraffic
    
    private var waypoints: [Waypoint] = []
    private var core: MapboxNavigation? = nil
    
    // Route Data
    @Published var route: Route?
    @Published var routeSteps: [[Step]]?
    @Published var legPolylines: [MKPolyline]?
    @Published var startCoordinate: CLLocationCoordinate2D?
    @Published var endCoordinate: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    // Continuously update user location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            if let location = locations.last {
                DispatchQueue.main.async {
                    self.userLocation = location.coordinate // Update user location
                    self.motion.coordinate = location.coordinate
                    self.motion.altitude = location.altitude
                    self.motion.speed = location.speed
                    self.motion.direction = location.course
                    print(self.motion.toString())
                    
                    // Update the region for the map
                    self.region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                }
            }
        }
    
    
    // Handle location access errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    // Source Setters
    func setSource(coord: CLLocationCoordinate2D) {
        self.source = MKPlacemark(coordinate: coord)
    }
    func setSource(placemark: MKPlacemark) {
        self.source = placemark
    }
    // Destination Setters
    func setDestination(coord: CLLocationCoordinate2D) {
        self.destination = MKPlacemark(coordinate: coord)
    }
    func setDestination(placemark: MKPlacemark) {
        self.destination = placemark
    }
    
    // Directions
    func getDirections() {
        self.route = nil
        
        // Check if there is a selected result
        
        // Create and configure the request
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: source)
        request.destination = MKMapItem(placemark: destination)
        // Get the directions based on the request
        Task {
            let directions = MKDirections(request: request)
            if let response = try? await directions.calculate() {
                DispatchQueue.main.async {
                    self.route = response.routes.first
                }
            }
        }
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
    
    func modifyWaypointsOrdering(newWaypoints: [Waypoint]) async throws {
        waypoints = newWaypoints
        if waypoints.count > 1 {
            try await updateRoutes()
        }
    }
    
    // Remove waypoint on route
    func removeWayPoint(waypoint: Waypoint) async throws {
        if let index = waypoints.firstIndex(of: waypoint) {
            waypoints.remove(at: index)
        }
        try await updateRoutes()
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
                            
        self.route = mainRoute
        self.routeSteps = getSteps(route: mainRoute)
        
        self.legPolylines = getPolylines(route: self.routeSteps!)
        self.startCoordinate = self.routeSteps?.first?.first?.startCoordinate
        self.endCoordinate = self.routeSteps?.last?.last?.endCoordinate


    }
    
    // Routing
    
    // Take a mapbox Route and convert to polylines, each polyline being a leg of the route
    private func getPolylines(route: [[Step]]) -> [MKPolyline] {
        var legs = [MKPolyline]()
        
        for leg in route {
            var stepCoordinates = [CLLocationCoordinate2D]()
            for step in leg {
                if let startCoordinate = step.startCoordinate {
                    stepCoordinates.append(startCoordinate)
                }
            }
            if let lastCoordinate = leg.last?.endCoordinate {
                stepCoordinates.append(lastCoordinate)
            }
            print(stepCoordinates)
            legs.append(MKPolyline(coordinates: stepCoordinates, count: stepCoordinates.count))
            
        }
        
        return legs
    }
    
    // Generate legs with Step structs
    private func getSteps(route: Route) -> [[Step]] {
        var legs = [[Step]]()
        for leg in route.legs {
            var steps = [Step]()
            for step in leg.steps {
                steps.append(Step(step: step))
            }
            legs.append(steps)
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
    
}