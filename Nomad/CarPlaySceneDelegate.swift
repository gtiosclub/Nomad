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
struct CarPlayMapContentView: MapContent {
    var mapMarkers: [MapMarker] // Replace with your marker type
    var mapPolylines: [MKPolyline]
    
    var body: some MapContent {
        UserAnnotation()
        
        ForEach(mapMarkers) { marker in
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
        
        ForEach(mapPolylines, id: \.self) { polyline in
            MapPolyline(polyline)
                .stroke(.blue, lineWidth: 5)
        }
    }
}

// MARK: - CarPlay Map View
struct CarPlayMapView: View {
    @ObservedObject var vm: UserViewModel
    @StateObject private var navManager = NavigationManager.nav
    @StateObject private var mapManager = MapManager.manager
    
    var body: some View {
        ZStack {
            // Map View
            Map(position: $navManager.mapPosition) {
                CarPlayMapContentView(
                    mapMarkers: navManager.mapMarkers,
                    mapPolylines: navManager.mapPolylines
                )
            }
            .mapControlVisibility(.hidden)
            
            // Navigation Overlay
            VStack {
                HStack {
                    CarPlayTopView()
                        .frame(width: 175, height: 40)
                    Spacer()
                }
                .padding(10)
                .padding(.leading, 45)
                Spacer()
                HStack {
                    CarPlayBottomNavView(navManager: navManager)
                        .frame(width: 175, height: 50)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    Spacer()
                    Image(systemName: "mic")
                        .padding(.trailing, 15)
                }
                .padding(.horizontal, 10)
                .padding(.leading, 30)
            }
        }
    }
}

struct CarPlayTopView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
            HStack {
                VStack {
                    Image(systemName: "arrow.turn.up.right")
                        .foregroundColor(.black)
                    Text("100 ft")
                        .font(.system(size: 10))
                        .foregroundColor(.black)
                }
                Text("Turn Right")
                    .font(.system(size: 24))
                    .foregroundColor(.black)
            }
        }
    }
}

struct CarPlayBottomNavView: View {
    // Change to ObservedObject since we're passing it in
    @ObservedObject var navManager: NavigationManager
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10.0)
            HStack {
                VStack {
                    Text("7:32")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    Text("arrival")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                Spacer()
                VStack {
                    Text("2:26")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    Text("hrs")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
                Spacer()
                VStack {
                    Text("121")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.black)
                    Text("mi")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 10)
        }
    }
}
