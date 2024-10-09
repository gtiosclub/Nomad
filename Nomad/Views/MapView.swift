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
    @ObservedObject var mapManager: MapManager
    
    var body: some View {
        ZStack {
            // All views within Map
            Map(position: $mapManager.mapPosition, interactionModes: MapInteractionModes.all) {
                // Adding markers for the start and finish points
                if let userLocation = mapManager.userLocation {
                    Marker("Your Location", coordinate: userLocation)
                }
                
                //show all markers
                ForEach(mapManager.mapMarkers) { marker in
                    Marker(marker.title, systemImage: marker.icon.image_path, coordinate: marker.coordinate)
                }
                // show all polylines
                ForEach(mapManager.mapPolylines, id:\.self) { polyline in
                    MapPolyline(polyline)
                        .stroke(.blue, lineWidth: 5)
                }
                
                
                
            }.mapStyle(getMapStyle())
                .onTapGesture {
                    mapManager.movingMap = true
                }
            
            // All Map HUD
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        CompassView(bearing: $mapManager.bearing)
                            .frame(width: 50, height: 50)
                        RecenterMapView(recenterMap: {
                            if let userLocation = mapManager.userLocation {
                                mapManager.mapPosition = .camera(MapCamera(centerCoordinate: userLocation, distance: mapManager.navigating ? 1000 : 5000, heading: (mapManager.navigating ? mapManager.motion.direction : 0) ?? 0, pitch: mapManager.navigating ? 80 : 0))
                                mapManager.movingMap = false
                            }
                        })
                        .frame(width: 50, height: 50)
                        ChangeMapTypeButtonView(selectedMapType: $mapManager.mapType)
                            .frame(width: 50, height: 50)
                    }
                }
                Spacer()
                LocationSearchBox(mapManager: mapManager)
                    .padding()
            }
        }
    }
    
    func getMapStyle() -> MapStyle {
        switch mapManager.mapType {
        case .defaultMap:
            return .standard
        case .satellite:
            return .imagery
        case .terrain:
            return .hybrid
        }
    }
}


#Preview {
    MapView(mapManager: MapManager())
}
