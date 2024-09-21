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
    @Published var route: MKRoute? = nil
    @Published var source = MKPlacemark(coordinate: CLLocationCoordinate2D())
    @Published var destination =  MKPlacemark(coordinate: CLLocationCoordinate2D())
    @Published var motion = Motion()
    
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
                self.motion.coordinate = location.coordinate
                self.motion.altitude = location.altitude
                self.motion.speed = location.speed
                self.motion.direction = location.course
                print(self.motion.toString())
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
}
