//
//  MapView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//
import SwiftUI
import MapKit
import AVFoundation

@available(iOS 17.0, *)
struct MapView: View {
    @Binding var tabSelection: Int
    @ObservedObject var vm: UserViewModel
    @ObservedObject var navManager: NavigationManager = NavigationManager()
    @ObservedObject var mapManager = MapManager.manager
    @State private var cameraDistance: CLLocationDistance = 400

    let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            // All views within Map
            Map(position: $navManager.mapPosition) {
                UserAnnotation()
                
                ForEach(navManager.mapMarkers) { marker in
                    if marker.icon == .trafficLight || marker.icon == .stopSign {
                        Annotation("", coordinate: marker.coordinate) {
                            VStack {
                                Image(marker.icon.image_path)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: min(100000 / (cameraDistance), 40), height: min(40, 100000 / (cameraDistance)))
                                    .opacity(cameraDistance > 8000 ? 0 : 1)
                                    .clipShape(Circle())
                                    .animation(.easeInOut, value: cameraDistance)
                                
                            }
                        }
                    } else {
                        Marker(marker.title, coordinate: marker.coordinate)
                    }
                }
                // show all polylines
                ForEach(navManager.mapPolylines, id:\.self) { polyline in
                    MapPolyline(polyline)
                        .stroke(.blue, lineWidth: 5)
                }
               }.mapControlVisibility(.hidden)
            MapHUDView(tabSelection: $tabSelection, vm: vm, navManager: navManager, mapManager: mapManager)
        }.environmentObject(navManager)
               
            .onChange(of: mapManager.motion, initial: true) { oldMotion, newMotion in
                if let newLoc = newMotion.coordinate {
                    if !navManager.destinationReached {
                    Task {
                        await navManager.recalibrateCurrentStep() // check if still on currentStep, and update state accordingly
                    }
                    navManager.distanceToNextManeuver = navManager.assignDistanceToNextManeuver()

                    }
                    
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
        }.onMapCameraChange { camera in
            withAnimation {
                cameraDistance = camera.camera.distance
            }
        }
    }
}
struct MapHUDView: View {
    @Binding var tabSelection: Int
    @ObservedObject var vm: UserViewModel
    @ObservedObject var navManager: NavigationManager
    @ObservedObject var mapManager: MapManager
    @State var isVoiceEnabled: Bool = false
    
    @State private var remainingTime: TimeInterval = 0
    @State private var remainingDistance: Double = 0
    @State var atlasSheetPresented = false
    @State private var navSheetPresented = false
    @ObservedObject var speechRecognizer = SpeechRecognizer()

    let timer = Timer.publish(every: 7, on: .main, in: .common).autoconnect()

    var body: some View {
        // All Map HUD
        VStack {
            if navManager.getNavigating() {
                DirectionView(navManager: navManager, step: navManager.navigatingStep!)
                    .padding()
            }
            HStack {
                Spacer()
                MapButtonsView(announceInstruction: announceInstruction, navManager: navManager, atlasSheetPresented: $atlasSheetPresented, isVoiceEnabled: $isVoiceEnabled)
                .padding(.trailing, 5)
                .padding(.bottom, 20)
                
            }
            
            Spacer()
            if vm.navigatingTrip == nil {
                Button {
                    self.tabSelection = 2
                } label: {
                    
                    HStack(spacing: 30) {
                        Image(systemName: "chevron.left") // hidden, used for centering
                            .font(.system(size: 25))
                            .foregroundStyle(.clear)
                        VStack(spacing: 15) {
                            Text("No Trip in Progress").bold()
                            Text("Select or create a new trip\n from the \"Plan\" tab")
                        }
                        Image(systemName: "chevron.right")
                            .font(.system(size: 25))
                            .foregroundStyle(.white)
                    }.multilineTextAlignment(.center)
                        .padding(20)
                        .frame(maxWidth: .infinity, minHeight: 120, idealHeight: 120)
                        .background(Color.nomadDarkBlue)
                        .foregroundStyle(.white)
                        .cornerRadius(20)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 5)
                }
            } else {
                if !navManager.getNavigating() {
                    BeginningNavigationView(vm: vm, navManager: navManager, mapManager: mapManager, startNavigation: {
                        startNavigation()
                            
                    }, cancel: { cancelNavigation()}).frame(height: 450)
                        .transition(.move(edge: .bottom))
                } else {
                    if !navManager.destinationReached {
                        BottomNavView(routeName: vm.navigatingTrip!.name, expectedTravelTime: mapManager.getRemainingTime(leg: navManager.navigatingLeg!), distance: mapManager.getRemainingDistance(leg: navManager.navigatingLeg!), cancel: cancelNavigation)
                            .offset(y: 20)
                    } else {
                        EndOfLegView(navManager: navManager, continueNavigation: { navManager.goToNextLeg() })
                        
                    }
                }
            }
        }.onAppear {
            speechRecognizer.pollForAtlas()
        }
        .onDisappear {
            speechRecognizer.resetTranscript()
        }.onChange(of: vm.navigatingTrip) { old, new in
            if let newTrip = new {
                if let newRoute = newTrip.route {
                    navManager.setNavigatingRoute(route: newRoute, trip: newTrip)
                }
            }
        }
        .onChange(of: navManager.navigatingStep) { oldValue, newValue in
            if navManager.getNavigating() {
                navManager.recenterMap()
            }
        }
        .onChange(of: speechRecognizer.atlasSaid) { atlasSaid in
            atlasSheetPresented = true
        }
        .sheet(isPresented: $atlasSheetPresented) {
            AtlasNavigationView(vm: vm, navManager: navManager)
                .onAppear {
                    speechRecognizer.resetTranscript()
                }
                .presentationDetents([.medium, .large])
                .onDisappear {
                    speechRecognizer.pollForAtlas()
                }
        }
        .onReceive(timer) { _ in
            // reset remaining time and distance
            Task {
                await timerUpdate()
            }
        }
    }
    
    private func timerUpdate() async {
        if navManager.getNavigating() {
            self.remainingTime = mapManager.getRemainingTime(leg: navManager.navigatingLeg!)
            self.remainingDistance = mapManager.getRemainingDistance(leg: navManager.navigatingLeg!)
        }
        // REROUTING SHOULD GO HERE
        
        Task {
            if !navManager.destinationReached {
                await navManager.recalibrateCurrentStep() // check if still on currentStep, and update state accordingly
                navManager.distanceToNextManeuver = navManager.assignDistanceToNextManeuver()
            }
        }
    }
    private func startNavigation() {
        // start
        if let trip = vm.navigatingTrip {
            navManager.setNavigatingRoute(route: trip.route!, trip: trip)
        }
        navManager.startNavigating()
        Task {
            await timerUpdate()
        }
    }
    private func cancelNavigation() {
        // cancel
        vm.navigatingTrip = nil
        navManager.navigatingRoute = nil
        navManager.navigatingLeg = nil
        navManager.navigatingStep = nil
        print("cancel")
        navManager.setNavigating(false)
    }

    private func formattedRemainingTime() -> String {
        let seconds = Int(navManager.remainingTime ?? 0)
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        
        return String(format: "%1d:%02d", hours, minutes)
    }
    private func formattedRemainingDistance() -> String {
        return String(format: "%.1f", (navManager.remainingDistance ?? 0) / 1609.34)
        //        var miles = self.remainingDistance / 1609.34
        //        if miles > 0.2 {
        //            return String(format: "%.1f miles", miles)
        //        } else {
        //            let feet = 100 * floor(miles * 5280 / 100)
        //            return String(format: "%3.0f feet", feet)
        //        }
    }
    // Function to announce current location
    private func announceInstruction() {
        let locationVoiceManager = LocationVoiceManager.shared
        
        let instruction = navManager.getStepInstruction()
        locationVoiceManager.announceInstruction(instruction)
    }
}

struct MapButtonsView: View {
    var announceInstruction: () -> Void
    @ObservedObject var navManager: NavigationManager
    @Binding var atlasSheetPresented: Bool
    @Binding var isVoiceEnabled: Bool
    var body: some View {
        VStack(spacing: 15){
            RecenterMapView(recenterMap: {
                navManager.recenterMap()
            })
            .frame(width: 50, height: 50)
            .shadow(color: .gray.opacity(0.8), radius: 8, x: 0, y: 5)
            
            // Add Voice Announcer Button
            VoiceAnnouncerButtonView(onPress: announceInstruction, isVoiceEnabled: $isVoiceEnabled)
                .frame(width: 50, height: 50)
                .shadow(color: .gray.opacity(0.8), radius: 8, x: 0, y: 5)
            
            Spacer()
            
            Button {
                atlasSheetPresented = true
            } label: {
                ZStack {
                    // White Circle with Drop Shadow
                    Circle()
                        .fill(Color.nomadDarkBlue)
                        .frame(width: 60, height: 60) // Adjust size as needed
                        .shadow(color: .gray.opacity(0.8), radius: 8, x: 0, y: 5)
                    
                    
                    Rectangle()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.white)
                        .mask {
                            // Image on top of the circle
                            Image("AtlasIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 45, height: 45) // Adjust size as needed
                        }
                }
            }
        }
    }
}


#Preview {
    MapView(tabSelection: Binding.constant(1), vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")))
}
