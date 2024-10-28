//
//  NavigationManager.swift
//  Nomad
//
//  Created by Nicholas Candello on 10/22/24.
//

import CoreLocation
import Foundation
import MapKit
import SwiftUI

import MapboxNavigationCore
import MapboxDirections


class NavigationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @ObservedObject var mapManager = MapManager.manager
    // Route State Info
    @Published var navigating = false
    @Published var navigatingRoute: NomadRoute? = nil
    @Published var navigatingLeg: NomadLeg? = nil
    @Published var navigatingStep: NomadStep? = nil
    
    // MAP UI Components
    @Published var mapMarkers: [MapMarker] = []
    @Published var mapPolylines: [MKPolyline] = []
    
    // Map UI Parameters
    @Published var mapPosition: MapCameraPosition = .userLocation(fallback: .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: .zero, longitude: .zero), distance: 0)))
    @Published var bearing: Double = 0.0
    @Published var mapType: MapTypes = .defaultMap
    @Published var region = MKCoordinateRegion()
    
    // navigation ui settings
    private let navPitch: Double = 30
    private let navDistance: Double = 800
    private let normalDistance: Double = 800
    
    // whether or not the user moved the map to another location manually
    
    func movingMap(camera: CLLocationCoordinate2D) -> Bool {
        let userLocation = mapManager.userLocation ?? CLLocationCoordinate2D()
        let variance = 0.001 // about 111 feet
        guard let camera = mapPosition.camera else { return false }
        if abs(userLocation.latitude - camera.centerCoordinate.latitude) > variance || abs(userLocation.longitude - camera.centerCoordinate.longitude) > variance {
            return true
        } else {
            return false
        }
    }
    
    // Route Controls
    
    func startNavigating() {
        if self.navigatingRoute == nil {
            print("No route assigned")
            self.navigating = false
        } else {
            // ui changes here
            self.navigatingStep  = navigatingRoute!.legs[0].steps[0]
            self.navigating = true
        }
    }
    func setNavigatingRoute(route: NomadRoute) {
        self.navigatingRoute = route
        self.mapPolylines.append(route.getShape())
    }
    func setNavigatingLeg(leg: NomadLeg) {
        self.navigatingLeg = leg
    }
    // jump to next leg of route, if no current leg is assigned, go to first leg in current route
    func goToNextLeg() {
        if let route = navigatingRoute {
            if let current_leg_index = route.legs.firstIndex(where: { leg in
                leg.id == navigatingLeg?.id
            }) {
                if current_leg_index < route.legs.count - 1 {
                    setNavigatingLeg(leg: route.legs[current_leg_index + 1])
                }
            } else {
                if let leg = route.legs.first {
                    setNavigatingLeg(leg: leg)
                }
            }
        }
    }
    func setNavigatingStep(step: NomadStep) {
        self.navigatingStep = step
    }
    // jump to next step of route, if no current step is assigned, go to first step in current leg
    func goToNextStep() {
        if let leg = navigatingLeg {
            if let current_step_index = leg.steps.firstIndex(where: { step in
                step.id == navigatingStep?.id
            }) {
                if current_step_index < leg.steps.count - 1 {
                    setNavigatingStep(step: leg.steps[current_step_index + 1])
                }
            } else {
                if let step = leg.steps.first {
                    setNavigatingStep(step: step)
                }
            }
        }
    }
    
    // Map UI Controls
    func recenterMap() {
        let mapManager = MapManager.manager
        let userMotion = mapManager.motion
        updateMapPosition(userMotion)
    }
    func updateMapPosition(_ userMotion: Motion) {
        guard let location = userMotion.coordinate else { return }
        guard let direction = userMotion.direction else { return }
        let bearing = direction >= 0 ? direction : 0
        withAnimation {
            mapPosition = .camera(MapCamera(centerCoordinate: location, distance: navigating ? navDistance : normalDistance, heading: bearing, pitch: navigating ? navPitch : 0))
        }
    }
    func getNavBearing() -> Double {
        let userLocation = mapManager.userLocation ?? CLLocationCoordinate2D()
        let motion = mapManager.motion
        if motion.direction ?? 0 > 0 {
            return motion.direction!.magnitude
        } else if navigating {
            if let route = navigatingRoute {
                let coord1 = userLocation
                let coord2 = route.getStartLocation()
                
                let lat1 = coord1.latitude.toRadians()
                let lon1 = coord1.longitude.toRadians()
                let lat2 = coord2.latitude.toRadians()
                let lon2 = coord2.longitude.toRadians()
                
                let deltaLon = lon2 - lon1
                
                let y = sin(deltaLon) * cos(lat2)
                let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLon)
                
                let initialBearing = atan2(y, x).toDegrees()
                
                // Normalize the bearing to a value between 0 and 360 degrees
                let compassBearing = (initialBearing + 360).truncatingRemainder(dividingBy: 360)
                
                return compassBearing
            }
        }
        return 0
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
}
