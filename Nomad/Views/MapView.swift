//
//  MapView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//
import SwiftUI
import MapKit
import AVFoundation

// Voice Button View
struct VoiceAnnouncerButtonView: View {
    let onPress: () -> Void
    @Binding var isVoiceEnabled: Bool
    
    var body: some View {
        Button(action: {
            isVoiceEnabled.toggle()
            if isVoiceEnabled {
                onPress()
            }
        }) {
            ZStack {
                Circle()
                    .fill(.white)
                    .shadow(radius: 4)
                Image(systemName: isVoiceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .foregroundColor(.blue)
            }
        }
    }
}

// Voice Manager
class LocationVoiceManager: ObservableObject {
    static let shared = LocationVoiceManager()
    private let synthesizer = AVSpeechSynthesizer()
    
    func announceLocation(_ locationDescription: String) {
        // Stop any ongoing speech
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: locationDescription)
        utterance.rate = 0.5
        utterance.volume = 1.0
        utterance.pitchMultiplier = 1.0
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        synthesizer.speak(utterance)
    }
}

@available(iOS 17.0, *)
struct MapView: View {
    @ObservedObject var vm: UserViewModel
    @ObservedObject var navManager: NavigationManager = NavigationManager()
    @ObservedObject var mapManager = MapManager.manager
    @StateObject private var voiceManager = LocationVoiceManager.shared
    @State private var isVoiceEnabled: Bool = false

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
                    navManager.recalibrateCurrentStep() // check if still on currentStep, and update state accordingly
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
                      
                        // Add Voice Announcer Button
                        VoiceAnnouncerButtonView(onPress: announceCurrentLocation, isVoiceEnabled: $isVoiceEnabled)
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
    // Function to announce current location
    private func announceCurrentLocation() {
        guard let userLocation = MapManager.manager.userLocation else { return }
        
        // Create a CLGeocoder instance
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        // Reverse geocode the location
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                // If geocoding fails, announce coordinates
                let announcement = "You are currently at latitude \(String(format: "%.4f", userLocation.latitude)) and longitude \(String(format: "%.4f", userLocation.longitude))"
                voiceManager.announceLocation(announcement)
                return
            }
            
            if let placemark = placemarks?.first {
                // Build location description
                var locationDescription = "You are currently at"
                
                if let streetNumber = placemark.subThoroughfare {
                    locationDescription += " \(streetNumber)"
                }
                
                if let street = placemark.thoroughfare {
                    locationDescription += " \(street)"
                }
                
                if let city = placemark.locality {
                    locationDescription += " in \(city)"
                }
                
                if let state = placemark.administrativeArea {
                    locationDescription += ", \(state)"
                }
                
                voiceManager.announceLocation(locationDescription)
            }
        }
    }
}

#Preview {
    MapView(vm: UserViewModel())
}
