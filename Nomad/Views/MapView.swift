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
    @State private var cameraDistance: CLLocationDistance = 400
    
    @State private var remainingTime: TimeInterval = 0
    @State private var remainingDistance: Double = 0
    
    var body: some View {
        ZStack {
            // All views within Map
            Map(position: $navManager.mapPosition) {
                UserAnnotation()
                
                ForEach(navManager.mapMarkers) { marker in
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
                }
                // show all polylines
                ForEach(navManager.mapPolylines, id:\.self) { polyline in
                    MapPolyline(polyline)
                        .stroke(.blue, lineWidth: 5)
                }
                
            }
            
            .onChange(of: mapManager.motion, initial: true) { oldMotion, newMotion in
                if let _ = newMotion.coordinate {
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
                    if navManager.navigating {
                        self.remainingTime = mapManager.getRemainingTime(leg: navManager.navigatingLeg!)
                        self.remainingDistance = mapManager.getRemainingDistance(leg: navManager.navigatingLeg!)
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
            
            // All Map HUD
            VStack {
                if navManager.navigating {
                    DirectionView(step: navManager.navigatingStep!)
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
                Button {
                    navManager.startNavigating()
                } label: {
                    Text("Start Navigating")
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .padding()
                }
                VStack {
                    Text("Time Remaining: \(formattedRemainingTime())")
                    Text("Distance: \(formattedRemainingDistance())")
                }
                
            }
        }.onChange(of: vm.navigatingTrip) { old, new in
            if let newTrip = new {
                if let newRoute = newTrip.route {
                    navManager.setNavigatingRoute(route: newRoute)
                }
            }
        }
    }
    private func formattedRemainingTime() -> String {
        let hours = floor(self.remainingTime / 3600)
        let minutes = floor(self.remainingTime.remainder(dividingBy: 3600) / 60)
        
        return "\(hours > 0 ? "\(hours) hrs " : "")\(minutes) mins"
    }
    private func formattedRemainingDistance() -> String {
        var miles = self.remainingDistance / 1609.34
        if miles > 0.2 {
            return String(format: "%.1f miles", miles)
        } else {
            let feet = 100 * floor(miles * 5280 / 100)
            return String(format: "%3.0f feet", feet)
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
    MapView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")))
}
