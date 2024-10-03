//
//  MapManager.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/16/24.
//

import Foundation
import MapKit

class MapManager: ObservableObject {
    
    
    // Route Data
    @Published var route: MKPolyline?
    @Published var source = MKPlacemark(coordinate: CLLocationCoordinate2D())
    @Published var destination =  MKPlacemark(coordinate: CLLocationCoordinate2D())
    
    private var directions: [MKDirections] = []
    
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
    
    func getDirections(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D, via stops: [CLLocationCoordinate2D]) {
            var allCoordinates = [start] + stops + [end]
            
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
