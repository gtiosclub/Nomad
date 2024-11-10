//
//  AtlasNavigationView.swift
//  Nomad
//
//  Created by Ganden Fung on 10/23/24.
//

import SwiftUI
import AVFoundation


struct AtlasNavigationView: View {
    @ObservedObject var vm = UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard"))
    @State var selectedTab = 0
    @State private var mapboxSetUp: Bool = false
    
    //@ObservedObject var AIVM = AIAssistantViewModel()
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
       utterance.rate = 0.5
        
       speechSynthesizer.speak(utterance)
   }
    
    var body: some View {
        VStack {
            Spacer()
            
            // Title
            Text("Where would you like to go?")
                .font(.title3)
                .padding(.bottom, 20)
            
            Spacer()
                .padding(.top, 10)
            // Microphone button
            Button(action: handleMicrophonePress) {
                Image(systemName: "mic.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .padding(.top, 125)
            }
            .padding(.bottom, 50)
            
            // "Type instead?" button
//            Button(action: {
//                // Action when "type instead" is pressed
//                print("Type instead pressed")
//            }) {
//                Text("type instead?")
//                    .foregroundColor(.gray)
//                    .underline()
//            }
            Text(currentMessage)
                .padding(10)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal, 10)
                .onChange(of: speechRecognizer.transcript) { newTranscript in
                    currentMessage = newTranscript
                }
            
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .foregroundColor(.white)
                    .scaleEffect(1.5) // Adjust the size of the loading circle
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

            
            Spacer()
                .padding(.bottom, 60)
        
        }
        .onChange(of: ChatVM.latestAIResponse) { response in
            if let response = response, !response.isEmpty {
                speak(text: response)
                toggleIsLoading()
            }
        }
    }
    
    
    func handleMicrophonePress() {
        print("Microphone button pressed")

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
