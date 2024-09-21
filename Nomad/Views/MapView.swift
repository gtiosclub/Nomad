//
//  MapView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//
import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct MapView: View {
    @ObservedObject var mapManager = MapManager()
    
    private let startingPoint = CLLocationCoordinate2D(
        latitude: 40.83657722488077,
        longitude: 14.306896671048852
    )
    
    private let destinationCoordinates = CLLocationCoordinate2D(
        latitude: 33.748997,
        longitude: -84.387985
    )
    
    var body: some View {
        Map {
            // Adding the marker for the starting point
            Marker("Start", coordinate: mapManager.source.coordinate)
            Marker("Finish", coordinate: mapManager.destination.coordinate)
            
            // Show the route if it is available
            if let route = mapManager.route {
                MapPolyline(route)
                    .stroke(.blue, lineWidth: 5)
            }
        }.onAppear() {
            mapManager.setSource(coord: startingPoint)
            mapManager.setDestination(coord: destinationCoordinates)
            mapManager.getDirections()
        }
    }
}


#Preview {
    MapView()
}
