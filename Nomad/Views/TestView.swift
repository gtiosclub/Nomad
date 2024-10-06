//
//  TestView.swift
//  Nomad
//
//  Created by Vignesh Suresh Kumar on 10/6/24.
//


import SwiftUI
import MapKit

struct TestView: View {
    @ObservedObject var mapManager = MapManager()
    
    @State var futureLocation: CLLocationCoordinate2D?
    let start = CLLocationCoordinate2D(latitude: .zero, longitude: .zero)
    let end = CLLocationCoordinate2D(latitude: 40.8296, longitude: -73.9262)
    
    
    var body: some View {
        Map(position: $mapManager.mapPosition, interactionModes: MapInteractionModes.all) {
            
            Marker("Start", coordinate: start)
            Marker("End", coordinate: end)
            
            ForEach(mapManager.mapPolylines, id:\.self) { polyline in
                MapPolyline(polyline)
                    .stroke(.blue, lineWidth: 5)
            }

            
            if let fl = futureLocation {
                Marker("Future", coordinate: fl)
            }
            
        }.task {
            await mapManager.setupMapbox()
            
            do {
                try await mapManager.addWaypoint(to: start)
                try await mapManager.addWaypoint(to: end)
                
                // 5 minutes later
                futureLocation = await mapManager.getFutureLocation(time: 300)
            } catch {
                print("Error: \(error)")
            }

            
        }
    }
}

#Preview {
    TestView()
}
