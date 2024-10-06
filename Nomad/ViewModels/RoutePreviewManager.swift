//
//  RoutePreviewManager.swift
//  Nomad
//
//  Created by Austin Huguenard on 10/4/24.
//

import Foundation
import MapKit
import CoreLocation
import SwiftUI

class RoutePreviewManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private var locationManager = CLLocationManager()
    
    @Published var route: MKPolyline? = nil
    @Published var source: CLLocationCoordinate2D? = nil
    @Published var destination: CLLocationCoordinate2D? = nil
    @Published var region = MKCoordinateRegion()
    @Published var stops: [CLLocationCoordinate2D] = []
    @Published var mapPosition: MapCameraPosition = .automatic
    @Published var mapType: MapTypes = .defaultMap
    private var directions: [MKDirections] = []
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func setSource(coord: CLLocationCoordinate2D) {
        self.source = coord
    }
    
    func setDestination(coord: CLLocationCoordinate2D) {
        self.destination = coord
    }
    
    func setStops(coords: [CLLocationCoordinate2D]) {
        self.stops = coords
    }
    
    func calculateDirections() {
        if let destination = self.destination, let source = self.source {
            
            let allCoordinates = [source] + self.stops + [destination]
            
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
}

