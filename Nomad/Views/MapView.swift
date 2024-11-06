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
                        .rotationEffect(.degrees((mapManager.motion.direction ?? navManager.mapPosition.camera?.heading) ?? 0))
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
            .onChange(of: mapManager.motion, initial: true) { oldMotion, newMotion in
                if let newLoc = newMotion.coordinate {
                    print("New User Location")
                    Task {
                        await navManager.recalibrateCurrentStep() // check if still on currentStep, and update state accordingly
                    }
                    navManager.distanceToNextManeuver = navManager.assignDistanceToNextManeuver()
                    if let camera = navManager.mapPosition.camera {
                        let movingMap = navManager.movingMap(camera: camera.centerCoordinate)
                        if !movingMap {
                            withAnimation {
                                navManager.updateMapPosition(newMotion)
                            }
                        }
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
                    DirectionView(distance: $navManager.distanceToNextManeuver, nextStep: navManager.nextStepManeuver)
                }
                HStack {
                    Spacer()
                    VStack {
                        RecenterMapView(recenterMap: {
                            navManager.recenterMap()
                        })
                        .frame(width: 50, height: 50)
                    }
                }
                Spacer()
                VStack {
                    Text("Add debugging info below:")
                    Text("ENTER HERE")
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
}

#Preview {
    MapView(vm: UserViewModel())
}
