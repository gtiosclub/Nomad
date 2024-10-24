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
    @ObservedObject var navManager: NavigationManager = NavigationManager()
    var body: some View {
        ZStack {
            // All views within Map
            Map(position: $navManager.mapPosition) {
                // Adding markers for the start and finish points
                if let userLocation = MapManager.manager.userLocation {
                    Marker("Your Location", coordinate: userLocation)
                }
                
                //show all markers
                ForEach(navManager.mapMarkers) { marker in
                    Marker(marker.title, systemImage: marker.icon.image_path, coordinate: marker.coordinate)
                }
                // show all polylines
                ForEach(navManager.mapPolylines, id:\.self) { polyline in
                    MapPolyline(polyline)
                        .stroke(.blue, lineWidth: 5)
                }
                
                
                
            }.mapStyle(getMapStyle())
                .onTapGesture {
                    print("Moving map")
                    navManager.movingMap = true
                }
            
            // All Map HUD
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        CompassView(bearing: $navManager.bearing)
                            .frame(width: 50, height: 50)
                        RecenterMapView(recenterMap: {
                            let mapManager = MapManager.manager
                            if let userLocation = mapManager.userLocation {
                                navManager.mapPosition = .camera(MapCamera(centerCoordinate: userLocation, distance: navManager.navigating ? 1000 : 5000, heading: (navManager.navigating ? mapManager.motion.direction : 0) ?? 0, pitch: navManager.navigating ? 80 : 0))
                                navManager.movingMap = false
                                
                            }
                        })
                        .frame(width: 50, height: 50)
                        ChangeMapTypeButtonView(selectedMapType: $navManager.mapType)
                            .frame(width: 50, height: 50)
                    }
                }
                Spacer()
                LocationSearchBox(vm: vm)
                    .padding()
            }
        }.onChange(of: MapManager.manager.userLocation, initial: true) { oldLocation, newLocation in
            if let newLoc = newLocation {
                updateMapPosition(newLoc)
            }
        }
    }
    
    func getMapStyle() -> MapStyle {
        switch navManager.mapType {
        case .defaultMap:
            return .standard
        case .satellite:
            return .imagery
        case .terrain:
            return .hybrid
        }
    }
    func updateMapPosition(_ userLocation: CLLocationCoordinate2D) {
        print("update map position")
        if (!navManager.movingMap) {
            navManager.mapPosition = .camera(MapCamera(centerCoordinate: userLocation, distance: navManager.navigating ? 1000 : 5000, heading: (navManager.navigating ? MapManager.manager.motion.direction : 0) ?? 0, pitch: navManager.navigating ? 80 : 0))
        }
        navManager.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: userLocation.latitude, longitude: userLocation.longitude),
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
}


#Preview {
    MapView(vm: UserViewModel())
}
