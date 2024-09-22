//
//  MapManager.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/16/24.
//

import Foundation
import MapKit

import MapboxNavigationCore

class MapManager: ObservableObject {
    
    
    // Route Data
    @Published var route: MKRoute?
    @Published var source = MKPlacemark(coordinate: CLLocationCoordinate2D())
    @Published var destination =  MKPlacemark(coordinate: CLLocationCoordinate2D())
    
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
            let response = try? await directions.calculate()
            route = response?.routes.first
            
        }
    }
}
