//
//  VoiceAnnouncerButtonView.swift
//  Nomad
//
//  Created by Nicholas Candello on 11/14/24.
//
import SwiftUI
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
                    .fill(Color.nomadDarkBlue)
                    .shadow(radius: 4)
                Image(systemName: isVoiceEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill")
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    VoiceAnnouncerButtonView(onPress: {}, isVoiceEnabled: Binding.constant(true))
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