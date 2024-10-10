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
    @ObservedObject var vm: UserViewModel
        
    var body: some View {
        ZStack {
            // All views within Map
            Map(position: $vm.mapManager.mapPosition, interactionModes: MapInteractionModes.all) {
                // Adding markers for the start and finish points
                if let userLocation = vm.mapManager.userLocation {
                    Marker("Your Location", coordinate: userLocation)
                }
                
                //show all markers
                ForEach(vm.mapManager.mapMarkers) { marker in
                    Marker(marker.title, systemImage: marker.icon.image_path, coordinate: marker.coordinate)
                }
                // show all polylines
                ForEach(vm.mapManager.mapPolylines, id:\.self) { polyline in
                    MapPolyline(polyline)
                        .stroke(.blue, lineWidth: 5)
                }
            
                
                
            }.mapStyle(getMapStyle())
          
            // All Map HUD
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        CompassView(bearing: $vm.mapManager.bearing)
                            .frame(width: 50, height: 50)
                        RecenterMapView(recenterMap: {
                            if let userLocation = vm.mapManager.userLocation {
                                vm.mapManager.mapPosition = .camera(MapCamera(centerCoordinate: userLocation, distance: 5000, heading: 0, pitch: 0))
                            }
                        })
                        .frame(width: 50, height: 50)
                        ChangeMapTypeButtonView(selectedMapType: $vm.mapManager.mapType)
                            .frame(width: 50, height: 50)
                    }
                }
                Spacer()
                LocationSearchBox(vm: vm)
                    .padding()
            }
        }
    }
    
    func getMapStyle() -> MapStyle {
        switch vm.mapManager.mapType {
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
    MapView(vm: UserViewModel())
}
