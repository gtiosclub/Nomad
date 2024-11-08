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
    @Published var offRouteCount: Int = 0
    @Published var distanceToNextManeuver: Double?
    var nextStepManeuver: NomadStep? {
        guard let navStep = navigatingStep else { return nil }
        if let currentIndex = navigatingLeg?.steps.firstIndex(where: { step in
            step.id == navStep.id
        }) {
            guard let nextStep = navigatingLeg?.steps[currentIndex + 1] else { return nil }
            return nextStep
        } else {
            return nil
        }
    }

    // MAP UI Components
    @Published var mapMarkers: [MapMarker] = []
    @Published var mapPolylines: [MKPolyline] = []
    
    // Map UI Parameters
    @Published var mapPosition: MapCameraPosition = .userLocation(fallback: .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: .zero, longitude: .zero), distance: 0)))
    
    // navigation ui settings
    private let navPitch: Double = 30
    private let navDistance: Double = 800
    private let normalDistance: Double = 800
    
    
    // NAV CONTROLS
    func startNavigating() {
        if self.navigatingRoute == nil {
            print("No route assigned")
            self.navigating = false
        } else {
            // ui changes here
            self.setNavigatingLeg(leg: navigatingRoute!.legs[0])
            self.setNavigatingStep(step: navigatingRoute!.legs[0].steps[0])
            self.navigating = true
        }
    }
    func setNavigatingRoute(route: NomadRoute) {
        self.navigatingRoute = route
        self.mapPolylines.removeAll()
        self.showPolyline(route: navigatingRoute!)
    }
    
    func setNavigatingLeg(leg: NomadLeg) {
        self.navigatingLeg = leg
        for step in leg.steps {
            print("\(step.direction.instructions) in \(step.direction.distance)")
        }
        
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
        guard let leg = navigatingLeg else { return }
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
    
    // TODO: Modify to make both distance and direction checks to re-route if so
    func recalibrateCurrentStep() async {
        guard let currentLeg = self.navigatingLeg else { return }
        guard let estimatedStep = mapManager.determineCurrentStep(leg: currentLeg) else { return }
        print(estimatedStep.direction.instructions)
        if estimatedStep.id != navigatingStep?.id {
            setNavigatingStep(step: estimatedStep)
        }
        
        // rerouting if step isn't working
        if let currStep = navigatingStep {
            let isDistance = mapManager.checkOnRouteDistance(step: currStep, thresholdDistance: 500)
            let isDirection = mapManager.checkOnRouteDirection(step: currStep, thresholdDirection: 90)
            
            offRouteCount = !isDistance || !isDirection ? offRouteCount + 1 : 0
            if offRouteCount == 2 {
                await reroute(leg: currentLeg, step: estimatedStep)
                offRouteCount = 0
            }
        }
    }
    // Generates new route and updates current leg with that information
    private func reroute(leg: NomadLeg, step: NomadStep) async {
        guard let userLocation = mapManager.userLocation else { return }
        let stopCoords = [userLocation, leg.getEndLocation()]
        guard let newRoutes = await mapManager.generateRoute(stop_coords: stopCoords) else { return }
        
        guard let newLeg = newRoutes.first?.legs.first else { return }
        guard let estimatedStep = mapManager.determineCurrentStep(leg: newLeg) else { return }
        
        let oldStepIndex = leg.steps.firstIndex { s in s.id == step.id } ?? 0
        var updatedSteps = navigatingLeg?.steps[..<oldStepIndex] ?? []
        updatedSteps.append(contentsOf: newLeg.steps)
        let updatedLeg = NomadLeg(steps: Array(updatedSteps))
                
        for (i, l) in self.navigatingRoute!.legs.enumerated() {
            if l.id == leg.id {
                self.navigatingRoute!.legs[i] = updatedLeg
            }
        }
        print("Old Leg: \(self.navigatingLeg!.id), New Leg: \(updatedLeg.id)")
        self.navigatingLeg = updatedLeg
        self.navigatingStep = estimatedStep
        
        setNavigatingRoute(route: self.navigatingRoute!)
        setNavigatingLeg(leg: self.navigatingLeg!)
        setNavigatingStep(step: self.navigatingStep!)
    }
    
    
    func onFirstStepOfLeg() -> Bool {
        guard let current_step = self.navigatingStep else { return false }
        guard let current_leg = self.navigatingLeg else { return false }
        if current_leg.steps[0].id == current_step.id {
            return true
        } else {
            return false
        }
        
    }
    
    // UI GETTERS
    func assignDistanceToNextManeuver() -> Double {
        print("1")
        guard let currentStep = self.navigatingStep else { return -1 }
        print("2")
        let currLoc = mapManager.getClosestCoordinate(step: currentStep) // closest route coordinate to user location
        guard let coord_index = currentStep.getCoordinates().firstIndex(where: { coord in
            coord == currLoc
        }) else { return -1 }
        print("3")
        let total_coord_count = currentStep.getCoordinates().count
        let distance = (Double(total_coord_count - coord_index)/Double(total_coord_count)) * currentStep.direction.distance
        print(distance)
        return distance
    }
    func getNavBearing(motion: Motion) -> Double {
        guard let userLocation = motion.coordinate else { return 0 }
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
    
    func recenterMap() {
        let userMotion = mapManager.motion
        updateMapPosition(userMotion)
    }
    func updateMapPosition(_ userMotion: Motion) {
        let minSpeed = 1.0 // minimum speed where maplocation should be updated
        guard let location = userMotion.coordinate else { return }
        guard let direction = userMotion.direction else { return }
        guard let speed = userMotion.speed else { return }
        let bearing = speed >= minSpeed ? direction : 0
            withAnimation {
                mapPosition = .camera(MapCamera(centerCoordinate: location, distance: navigating ? navDistance : normalDistance, heading: getNavBearing(motion: userMotion), pitch: navigating ? navPitch : 0))
        }
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
    func showPolyline(route: NomadRoute) {
        mapPolylines.append(route.getShape())
    }
    func removePolyline(route: NomadRoute) {
        mapPolylines.removeAll { polyline in
            polyline == route.getShape() // might not work if polyline is not equatable by geometry
        }
    }
}
