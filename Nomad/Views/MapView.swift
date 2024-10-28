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
    @ObservedObject var mapManager = MapManager.manager
    var body: some View {
        ZStack {
            // All views within Map
            Map(position: $navManager.mapPosition) {
                // Adding markers for the start and finish points
                Annotation("", coordinate: mapManager.userLocation ?? CLLocationCoordinate2D()) {
                    Image("nav_user_icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 50)
                        .background(.white)
                        .clipShape(Circle())
                        .rotationEffect(.degrees(mapManager.motion.direction ?? 0))
                }
                
                //show all markers
                ForEach(navManager.mapMarkers) { marker in
                    Marker(marker.title, coordinate: marker.coordinate)
                }
                // show all polylines
                ForEach(navManager.mapPolylines, id:\.self) { polyline in
                    MapPolyline(polyline)
                        .stroke(.blue, lineWidth: 5)
                }
                
            }
//            .onMapCameraChange { mapCameraUpdateContext in
//                let camera = mapCameraUpdateContext.camera
//                let movingMap = navManager.movingMap(camera: camera.centerCoordinate)
//                print("Moving map camera change: \(movingMap)")
//                if !movingMap {
//                    withAnimation {
//                        navManager.updateMapPosition(camera.centerCoordinate)
//                    }
//                }
//            }
            .onChange(of: mapManager.motion, initial: true) { oldMotion, newMotion in
                if let newLoc = newMotion.coordinate {
                    print("New Location: \(newLoc.latitude), \(newLoc.longitude)")
                    if let camera = navManager.mapPosition.camera {
                        let movingMap = navManager.movingMap(camera: camera.centerCoordinate)
                        print("Moving map user change: \(movingMap)")
                        if !movingMap {
                            withAnimation {
                                navManager.updateMapPosition(newMotion)
                            }
                        }
                    }
                    if let step = navManager.navigatingStep {
                        print("On current step? \(mapManager.checkOnRoute(step: step))")
                    }
                }
            }
            .onAppear() {
                let motion = mapManager.motion
                navManager.updateMapPosition(motion)
            }
            
            // All Map HUD
            VStack {
                if navManager.navigating {
                    DirectionView(step: $navManager.navigatingStep)
                }
                HStack {
                    Spacer()
                    VStack {
                        CompassView(bearing: navManager.mapPosition.camera?.heading ?? 0)
                            .frame(width: 50, height: 50)
                        RecenterMapView(recenterMap: {
                            navManager.recenterMap()
                        })
                        .frame(width: 50, height: 50)
                        ChangeMapTypeButtonView(selectedMapType: $navManager.mapType)
                            .frame(width: 50, height: 50)
                    }
                }
                Spacer()
                VStack {
                    Text("Location Info")
                    Text(mapManager.motion.toString())
                }
                HStack {
                    Button {
                        // set example route
                        Task {
                            if let route = await mapManager.getExampleRoute() {
                                navManager.setNavigatingRoute(route: route)
                            }
                            
                        }
                    } label: {
                        Text("Generate Route")
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .padding()
                    }
                    Button {
                        navManager.startNavigating()
                    } label: {
                        Text("Start Navigating")
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .padding()
                    }


                }
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
}

#Preview {
    MapView(vm: UserViewModel())
}
