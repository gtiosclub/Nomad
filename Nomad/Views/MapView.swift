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
        // TODO: Add local region for coordinates
        Map(interactionModes: MapInteractionModes.all) {
            // Adding the marker for the starting point
            if let startCoordinate = mapManager.startCoordinate {
                Marker("Start", coordinate: startCoordinate)
            }
            if let endCoordinate = mapManager.endCoordinate {
                Marker("End", coordinate: endCoordinate)

            }

            
            // Show the route if it is available
            if let legPolylines = mapManager.legPolylines {
                ForEach(legPolylines, id:\.self) { polyline in
                    MapPolyline(polyline)
                        .stroke(.blue, lineWidth: 5)
                }
            }

            
        }.task {
            do {
                await mapManager.setupMapbox()
                try await mapManager.addWaypoint(to: startingPoint)
                try await mapManager.addWaypoint(to: destinationCoordinates)
                mapManager.getDirections()
            } catch {
                print("ERrors \(error)")
            }
        }
    }
}


#Preview {
    MapView()
}
