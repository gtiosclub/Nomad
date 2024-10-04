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

class MapManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    
    // Route Data
    @Published var userLocation: CLLocationCoordinate2D?
    @Published var route: MKPolyline?
    @Published var source = MKPlacemark(coordinate: CLLocationCoordinate2D())
    @Published var destination =  MKPlacemark(coordinate: CLLocationCoordinate2D())
    @Published var motion = Motion()
    private var directions: [MKDirections] = []
    @Published var region = MKCoordinateRegion()
    
    // Map State/Settings
    @Published var mapPosition: MapCameraPosition = .userLocation(fallback: .camera(MapCamera(centerCoordinate: CLLocationCoordinate2D(latitude: .zero, longitude: .zero), distance: 0)))
    @Published var bearing: Double = 0.0
    @Published var mapType: MapTypes = .defaultMap
    
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
//    func getDirections() {
//        self.route = nil
//        
//        // Check if there is a selected result
//        
//        // Create and configure the request
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: source)
//        request.destination = MKMapItem(placemark: destination)
//        // Get the directions based on the request
//        Task {
//            let directions = MKDirections(request: request)
//            if let response = try? await directions.calculate() {
//                DispatchQueue.main.async {
//                    self.route = response.routes.first
//                }
//            }
//        }
//    }
    
    func getDirections(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, via stops: [CLLocationCoordinate2D]) {
        let allCoordinates = [start] + stops + [end]
        
        var polylines: [MKPolyline] = []
        
        func calculateNextLeg(index: Int) {
            guard index < allCoordinates.count - 1 else {
                let combinedPoints = polylines.flatMap { polyline in
                    Array(UnsafeBufferPointer(start: polyline.points(), count: polyline.pointCount))
                }
                
                let combinedPolyline = MKPolyline(points: combinedPoints, count: combinedPoints.count)
                DispatchQueue.main.async {
                    self.route = combinedPolyline
                }
                return
            }
            
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: allCoordinates[index]))
            request.destination = MKMapItem(placemark: MKPlacemark(coordinate: allCoordinates[index + 1]))
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            self.directions.append(directions)
            
            directions.calculate { [weak self] response, error in
                if let error = error {
                    print("Error calculating directions: \(error)")
                    return
                }
                guard let route = response?.routes.first else { return }
                polylines.append(route.polyline)
                calculateNextLeg(index: index + 1)
            }
        }
        calculateNextLeg(index: 0)
    }
}
