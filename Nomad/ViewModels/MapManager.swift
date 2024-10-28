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
    @Published var navigating = false
    @Published var movingMap = false
    
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
    func showPolyline(step: NomadStep) {
        mapPolylines.append(step.getShape())
    }
    
    func removePolyline(step: NomadStep) {
        mapPolylines.removeAll { polyline in
            polyline == step.getShape() // might not work if polyline is not equatable by geometry
        }
    }
    
    func showPolyline(leg: NomadLeg) {
        mapPolylines.append(leg.getShape())
    }
    
    func removePolyline(leg: NomadLeg) {
        mapPolylines.removeAll { polyline in
            polyline == leg.getShape() // might not work if polyline is not equatable by geometry
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
                // print(self.motion.toString())
                
                if let userLocation = self.userLocation {
                    if (!self.movingMap) {
                        self.mapPosition = .camera(MapCamera(centerCoordinate: userLocation, distance: self.navigating ? 1000 : 5000, heading: (self.navigating ? self.motion.direction : 0) ?? 0, pitch: self.navigating ? 80 : 0))
                    }
                }
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
    public static func generateRoute(coords: [[CLLocationCoordinate2D]]) async -> NomadRoute? {
        var legs = [NomadLeg]()
        let directions = Directions.shared
        
        for legCoords in coords {
            let options = MatchOptions(coordinates: legCoords)
            options.includesSteps = true
            
            let directions = Directions.shared
            
            let result = await withCheckedContinuation { continuation in
                directions.calculate(options) { result in
                    continuation.resume(returning: result)
                }
            }
            
            switch result {
            case .failure(let error):
                print("Could not generate route from coordinates: \(error)")
            case .success(let response):
                if let leg = response.matches?.first?.legs.first {
                    legs.append(NomadLeg(leg: leg))
                }
            }
        }
        
        return NomadRoute(legs: legs)
    }
    
    func getDirections() {
        
        // Check if there is a selected result'
        guard let previewRoutes = currentPreviewRoutes else { return }
        let mainRoute = previewRoutes.mainRoute.route
        print(mainRoute.legs.count)
                        
        let routeLegs = getLegs(route: mainRoute)
        let newRoute = NomadRoute(route: mainRoute, legs: routeLegs)
      
        self.routes.append(newRoute)
        for leg in newRoute.legs {
            showPolyline(leg: leg)
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
    
    private func jsonToCoordinates(values: KeyedDecodingContainer<MapManager.CodingKeys>) throws -> [CLLocationCoordinate2D] {
        let coordinatesJSON = try values.decode(String.self, forKey: .coordinates)
        let coordinates = coordinatesJSON.split(separator: ";").map { coord in
            return parseCoordinateString(coordString: String(coord))
        }
        
        return coordinates
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
    
    // Route progress functions
    func getFutureLocation(time: TimeInterval) async throws -> CLLocationCoordinate2D {
        var routeProgress: RouteProgress
        
        if let rp = await self.core?.navigation().currentRouteProgress?.routeProgress {
            routeProgress = rp
            if routeProgress.durationRemaining <= time {
                return self.mapMarkers.last?.coordinate ?? CLLocationCoordinate2D()
            }
        } else { // Creating a RouteProgress if this function called for a route that hasn't been started
            getDirections()
            if let currRoutes = self.currentPreviewRoutes {
                routeProgress = RouteProgress(navigationRoutes: currRoutes, waypoints: self.waypoints)
                // A newly-generated RouteProgress has no expected travel time in it
                if currRoutes.mainRoute.route.expectedTravelTime <= time {
                    return self.mapMarkers.last?.coordinate ?? CLLocationCoordinate2D()
                }
            } else {
                throw("Cannot get future location with no routes")
            }
        }
        
        var currTime = 0.0
        var currStep = routeProgress.currentLegProgress.currentStep
        var remainingSteps = routeProgress.currentLegProgress.remainingSteps
        var remainingLegs = routeProgress.remainingLegs
        
        while currTime < time {
            if remainingSteps.isEmpty && !remainingLegs.isEmpty {
                let newLeg = remainingLegs.removeFirst()
                remainingSteps = newLeg.steps
            }
            
            currStep = remainingSteps.removeFirst()
            currTime += currStep.typicalTravelTime ?? currStep.expectedTravelTime
        }
        
        return currStep.shape?.coordinates.last ?? CLLocationCoordinate2D()
    }
    
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
    
    // TODO: Convert to JSON
    func encode(to encoder: Encoder) throws {
        
    }
    
}
