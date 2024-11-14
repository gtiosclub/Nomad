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
    @State var selectedTab = 0
    @State private var mapboxSetUp: Bool = false
    @State var isListening = false
    
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
        utterance.rate = 0.55  // Try increasing this value to speed up the speech
        utterance.volume = 1.0
        
       speechSynthesizer.speak(utterance)
   }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Title
            Text("Atlas")
                .font(.title)
                .padding(.bottom, 20)
            
            Divider()
            
            Spacer()
                .padding(.top, 10)
            
            Text(currentMessage)
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal, 10)
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
            
            if isLoading {
                AtlasLoadingView(isAtlas: false)
                    .frame(width: 40, height: 40)
            } else {
                if isListening {
                    SoundwaveView()
                        .frame(height: 100)
                        .padding()
                } else {
                    Button(action: handleMicrophonePress) {
                        Image(systemName: "mic.circle")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .padding(.top, 125)
                    }
                    .padding(.bottom, 50)
                }
            }

            
            if let response = ChatVM.latestAIResponse, !response.isEmpty {
                HStack {
                    Text(response)
                        .padding(10)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                    Spacer()
                }
                .transition(.opacity)
            }
            
            if !ChatVM.pois.isEmpty {
                TabView {
                    ForEach(ChatVM.pois) { poi in
                        POIDetailView(name: poi.name, address: poi.address, distance: poi.distance, phoneNumber: poi.phoneNumber, image: poi.image, rating: poi.rating, price: poi.price, time: poi.time, latitude: poi.latitude, longitude: poi.longitude, city: poi.city, vm: vm, aiVM: AIVM)
                            .frame(width: 400, height: 120) // Adjust width and height as needed
                            .padding(.horizontal, 5) // Adds padding at the top and bottom
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 180)  // Adjust to fit the padding and content
            }
            Spacer()
                .padding(.bottom, 60)
            }
            .onChange(of: ChatVM.pois) { response in
                speak(text: ChatVM.latestAIResponse ?? "")
                //toggleIsLoading()
                isLoading = false
                isListening = false
            }
            

        
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
}

struct AtlasNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        AtlasNavigationView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")))
    }
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

//class AudioLevelMonitor: ObservableObject {
//    private var audioEngine: AVAudioEngine!
//    private var inputNode: AVAudioInputNode!
//    
//    @Published var audioLevel: CGFloat = 0.0
//    private var timer: Timer?
//    
//    init() {
//        setupAudioEngine()
//    }
//    
//    private func setupAudioEngine() {
//        audioEngine = AVAudioEngine()
//        inputNode = audioEngine.inputNode
//        let inputFormat = inputNode.outputFormat(forBus: 0)
//        
//        inputNode.installTap(onBus: 0, bufferSize: 2048, format: inputFormat) { buffer, _ in
//            self.processAudioBuffer(buffer: buffer)
//        }
//        
//        try? audioEngine.start()
//    }
//    
//    private func processAudioBuffer(buffer: AVAudioPCMBuffer) {
//        guard let channelData = buffer.floatChannelData?[0] else { return }
//        let channelDataArray = Array(UnsafeBufferPointer(start: channelData, count: Int(buffer.frameLength)))
//        
//        // Calculate RMS (Root Mean Square) for the audio levels
//        let rms = sqrt(channelDataArray.map { $0 * $0 }.reduce(0, +) / Float(buffer.frameLength))
//        let level = max(0, CGFloat(rms) * 20)  // Scale the value for display
//        
//        DispatchQueue.main.async {
//            self.audioLevel = level
//        }
//    }
//    
//    deinit {
//        audioEngine.stop()
//        inputNode.removeTap(onBus: 0)
//    }
//}
//
