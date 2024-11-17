//
//  CarPlaySceneDelgate.swift
//  Nomad
//
//  Created by Shaunak Karnik on 11/6/24.
//

import UIKit
import CarPlay
import os.log
import SwiftUI
import MapKit


// MARK: - CarPlaySceneDelegate
class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    @ObservedObject var vm: UserViewModel = UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard"))
    private var hostingController: UIHostingController<CarPlayMapView>?
    var carWindow: CPWindow?
    var interfaceController: CPInterfaceController?
    var mapTemplate: CPMapTemplate?
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController,
        to window: CPWindow
    ) {
        print("🚙 Connected to CarPlay.")
        
        self.interfaceController = interfaceController
        self.carWindow = window
        
        // Initialize CarPlay map view that mirrors the phone's navigation
        let carPlayMapView = CarPlayMapView(vm: vm)
        let hostingController = UIHostingController(rootView: carPlayMapView)
        self.hostingController = hostingController
        
        // Set the hosting controller as root
        window.rootViewController = hostingController
    }
    
    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didDisconnect interfaceController: CPInterfaceController
    ) {
        print("🚙 Disconnected from CarPlay.")
        self.interfaceController = nil
        self.carWindow = nil
    }
}

// MARK: - Simple CarPlay MapView
struct CarPlayMapView: View {
    @ObservedObject var vm: UserViewModel
    @StateObject private var navManager = NavigationManager.nav
    @StateObject private var mapManager = MapManager.manager
    
    var body: some View {
        Map(position: $navManager.mapPosition) {
            // Show user location
            UserAnnotation()
            
            // Show markers
            ForEach(navManager.mapMarkers) { marker in
                if marker.icon == .trafficLight || marker.icon == .stopSign {
                    Annotation("", coordinate: marker.coordinate) {
                        Image(marker.icon.image_path)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)
                            .clipShape(Circle())
                    }
                } else {
                    Marker(marker.title, coordinate: marker.coordinate)
                }
            }
            
            // Show route polylines
            ForEach(navManager.mapPolylines, id: \.self) { polyline in
                MapPolyline(polyline)
                    .stroke(.blue, lineWidth: 5)
            }
        }
        .mapControlVisibility(.hidden)
        .onChange(of: mapManager.motion) { _, newMotion in
            if let newLocation = newMotion.coordinate {
                if !navManager.destinationReached {
                    Task {
                        await navManager.recalibrateCurrentStep()
                    }
                    navManager.distanceToNextManeuver = navManager.assignDistanceToNextManeuver()
                }
                
                if let camera = navManager.mapPosition.camera,
                   !navManager.movingMap(camera: camera.centerCoordinate) {
                    withAnimation {
                        navManager.updateMapPosition(newMotion)
                    }
                }
            }
        }
        .onAppear {
            let motion = mapManager.motion
            navManager.updateMapPosition(motion)
        }
    }
}
