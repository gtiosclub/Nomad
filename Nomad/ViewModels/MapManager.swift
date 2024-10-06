//
//  MapManager.swift
//  Nomad
//
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
        
    // Data populated on MapView
    @Published var mapMarkers: [MapMarker] = []
    @Published var mapPolylines: [MKPolyline] = []

    
    // Map State/Settings
    @Published var mapPosition: MapCameraPosition = .userLocation(fallback: .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: .zero, longitude: .zero), distance: 0)))
    @Published var bearing: Double = 0.0
    @Published var mapType: MapTypes = .defaultMap
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var motion = Motion()
    @Published var region = MKCoordinateRegion()
    
    // Route Data
    @Published var routes: [NomadRoute] = []
    @Published private(set) var currentPreviewRoutes: NavigationRoutes?
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    // MAPMARKER CRUD
    func showMarker(_ title: String, coordinate: CLLocationCoordinate2D, icon: MapMarker.MapMarkerIcon?) {
        mapMarkers.append(MapMarker(coordinate: coordinate, title: title, icon: icon ?? .pin))
    }
    
    func removeMarker(markerId: UUID) {
        mapMarkers.removeAll { marker in
            marker.id == markerId
        }
    }
    
    // MAPPOLYLINE CRUD
    func showPolyline(step: Step) {
        mapPolylines.append(step.routeShape)
    }
    
    func removePolyline(step: Step) {
        mapPolylines.removeAll { polyline in
            polyline == step.routeShape // might not work if polyline is not equatable by geometry
        }
    }
    
    /// LOCATION MANAGER FUNCTIONS
    private var locationManager = CLLocationManager()
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
    
    // Route getters
    // TODO: Add getters for start end coords of each leg

    
    // MAPBOX FUNCTIONS
    func setupMapbox() async {
        let config = CoreConfig(credentials: .init())
        let navigatorProvider = MapboxNavigationProvider(coreConfig: config)
        self.core = await navigatorProvider.mapboxNavigation
    }
    
    
    /// ROUTE GENERATION FUNCTIONS
    private var profileIdentifier: ProfileIdentifier = .automobileAvoidingTraffic

    func getDirections() {
        
        // Check if there is a selected result'
        guard let previewRoutes = currentPreviewRoutes else { return }
        let mainRoute = previewRoutes.mainRoute.route
        print(mainRoute.legs.count)
                        
        let routeSteps = getSteps(route: mainRoute)
        let newRoute = NomadRoute(route: mainRoute, steps: routeSteps)
        self.routes.append(newRoute)
        for step in newRoute.steps {
            showPolyline(step: step)
        }
    }
    
    // Update generated route based on changes to waypoints
    private func updateRoutes() async throws {
        print("update routes")
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
            currentPreviewRoutes = previewRoutes
            getDirections()
        } else {
            print("error: no routing provider")
        }
    }
    
    // Make an alternative route the main route
    func selectAlternativeRoute(_ alternativeRoute: AlternativeRoute) async {
        if let previewRoutes = currentPreviewRoutes {
            currentPreviewRoutes = await previewRoutes.selecting(alternativeRoute: alternativeRoute)
        }
    }
    
    // ROUTE GENERATION HELPERS
    
    // Generate legs with Step structs
    private func getSteps(route: Route) -> [Step] {
        var steps = [Step]()
        for leg in route.legs {
            for step in leg.steps {
                steps.append(Step(step: step))
            }
        }
        return steps
    }
    
    /// WAYPOINT CRUD SECTION
    private var waypoints: [Waypoint] = []
    private var core: MapboxNavigation? = nil
    
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
    // TODO: Update MapPoint name
    private func toMapPoint(coordinates: CLLocationCoordinate2D) -> MapPoint {
        return MapPoint(name: "", coordinate: coordinates)
    }
    
}
