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
        latitude: 40.849761,
        longitude: 14.263364
    )
    
    var body: some View {
        Map {
            Marker("Start", coordinate: mapManager.source.coordinate)
            Marker("Finish", coordinate: mapManager.destination.coordinate)
        }.onAppear() {
            mapManager.setSource(coord: startingPoint)
            mapManager.setDestination(coord: destinationCoordinates)
            mapManager.getDirections(from: startingPoint, to: destinationCoordinates, via: [])
        }
    }
}

#Preview {
    MapView()
}
