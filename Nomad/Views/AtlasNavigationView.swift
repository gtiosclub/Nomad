//
//  AtlasNavigationView.swift
//  Nomad
//
//  Created by Ganden Fung on 10/23/24.
//

import SwiftUI
import AVFoundation


struct AtlasNavigationView: View {
    @ObservedObject var vm: UserViewModel
    @ObservedObject var navManager: NavigationManager
    @State var selectedTab = 0
    @State private var mapboxSetUp: Bool = false
    @State var isListening = false
    @State private var dotCount = 1
    let timer = Timer.publish(every:0.5, on: .main, in: .common).autoconnect()
    
    @ObservedObject var AIVM = AIAssistantViewModel()
    @ObservedObject var ChatVM = ChatViewModel()
    @State private var AIResponse: String? {
        didSet {
            if let response = AIResponse {
                speak(text: response)
            }
        }
    }
    
    //create speechRecognizer object
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isMicrophone = false
    @State private var currentMessage: String = ""
    //@State private var AIResponse: String = ""
    
    @State private var isLoading: Bool = false

    let speechSynthesizer = AVSpeechSynthesizer()
    
    func speak(text: String) {
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = 0.50  // Try increasing this value to speed up the speech
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1
        
       speechSynthesizer.speak(utterance)
   }
    
    var body: some View {
        VStack {
            
            // Title
            Text("Atlas")
                .font(.title)
                .fontWeight(.bold)
                .padding(.top, 10)
            
            Divider()
                .padding(.top, -8)
            
            ChatMessagesView(chatViewModel: ChatVM, dotCount: dotCount, timer: timer)
            
            if !ChatVM.pois.isEmpty {
                POICarouselView(chatViewModel: ChatVM, vm: vm, aiViewModel: AIVM, addStop: addStop)
                    .padding(.bottom, 0)
            }
            
            if isListening {
                Text(currentMessage)
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .padding(.horizontal, 10)
                    .padding(.bottom, 10)
                    .onChange(of: speechRecognizer.transcript) { newTranscript in
                        if newTranscript != ""
                        {
                            currentMessage = newTranscript
                            print("on change of speechRecognizer.transcript")
                        }
                       
                    }
                    .onChange(of: speechRecognizer.voiceRecordingTranscript) { newValue in
                        // Handle the change here
                        if newValue != ""{
                            print("Atlas Navigation View: \(newValue)")
                            currentMessage = newValue
                            ChatVM.sendMessage(currentMessage, vm: vm)
                            isLoading = true
                            isMicrophone = false
                        }
                    }
            }
            
            
            if isLoading {
                AtlasLoadingView(isAtlas: false)
                    .frame(width: 100, height: 100)
            } else {
                if isListening {
                    SoundwaveView()
                        .frame(height: 50)
                        .padding()
                } else {
                    Button(action: handleMicrophonePress) {
                        Image(systemName: "mic.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                    }
                }
            }
        }
        .onChange(of: speechRecognizer.atlasSaid) { atlasSaid in
            if atlasSaid {
                handleMicrophonePress()
                speechRecognizer.atlasSaid = false
            }
        }
        .onChange(of: ChatVM.responseArrived) { response in
            if ChatVM.responseArrived {
                speak(text: ChatVM.latestAIResponse ?? "")
                //toggleIsLoading()
                isLoading = false
                isListening = false
                currentMessage = ""
                ChatVM.responseArrived = false
            }
            
        }
        .onAppear {
            handleMicrophonePress()
            speechRecognizer.atlasSaid = false
        }
//        .onDisappear {
//            speechRecognizer.stopTranscribing()
//            speechRecognizer.resetTranscript()
//            isListening = false
//            isMicrophone = false
//        }
        
    }
    
    
    func handleMicrophonePress() {
        print("Microphone button pressed")
        isListening = true

        if isMicrophone {
            speechRecognizer.stopTranscribing()
            let transcript = speechRecognizer.transcript

            if !transcript.isEmpty {
                currentMessage = transcript
                ChatVM.sendMessage(currentMessage, vm: vm)
                isLoading = true
            }

            isMicrophone = false
        } else {
            speechRecognizer.startTranscribing()
            isMicrophone = true
        }
    }
    
    func toggleIsLoading() {
        isLoading.toggle()
    }
    
    func addStop(_ stop: any POI) {
        Task {
            do {
                let newTrip = try await navManager.updateTripAndRoute(stop: stop)
                vm.setCurrentTrip(trip: newTrip)
            } catch {
                print(error)
            }
        }
    }
}

#Preview {
    AtlasNavigationView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")), navManager: NavigationManager())
}
struct SoundwaveView: View {
    @ObservedObject var speechRecognizer = SpeechRecognizer.shared

    var body: some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(0..<20) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: 5, height: self.barHeight(for: index))
                }
            }
            .frame(height: 100)
        }
        .padding()
    }
    
    private func barHeight(for index: Int) -> CGFloat {
        let randomizedLevel = SpeechRecognizer.shared.audioLevel * CGFloat.random(in: 0.5...1.5)
        return max(10, randomizedLevel * 100)
    }
}

