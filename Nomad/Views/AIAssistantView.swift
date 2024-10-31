//
//  AIAssistantView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct AIAssistantView: View {
    @StateObject var aiViewModel = AIAssistantViewModel()
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isMicrophone = false

    @State private var currentMessage: String = ""
    

    var body: some View {
        VStack {
            HStack {
                Text("Let's plan your new trip")
                    .font(.title2)
                    .padding()
                Spacer()
            }
            
            List(chatViewModel.messages) { message in
                HStack {
                    if message.sender == "AI" {
                        Text(message.content)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(10)
                        Spacer()
                    } else {
                        Spacer()
                        
                        Text(message.content)
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(10)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(PlainListStyle())
            .background(Color.clear)
            
            // Horizontal scroll view for POIs
            if !chatViewModel.pois.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(chatViewModel.pois) { poi in
                            POIDetailView(name: poi.name, address: poi.address, distance: poi.distance)
                                .frame(width: 400) // Adjust width as necessary
                        }
                    }
                    .padding(.horizontal)
                }
                .frame(height: 150)  // Adjust height as needed
            }
            
            HStack {
                Button(action: {
                    // Microphone action if necessary
                    if isMicrophone {
                        speechRecognizer.stopTranscribing()
                        let transcript = speechRecognizer.transcript
                        
                        if !transcript.isEmpty {
                            //viewModel.sendMessage(transcript)
                            //currentMessage = transcript
                        }
                        
                        isMicrophone = false
                    } else {
                        speechRecognizer.startTranscribing()
                        isMicrophone = true
                    }
                }) {
                    Image(systemName: "microphone.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .foregroundColor(isMicrophone ? .red : .gray)
                }
                TextField("Ask me anything...", text: $currentMessage)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(minHeight: 40)
                    .onChange(of: speechRecognizer.transcript) { newTranscript in
                        currentMessage = newTranscript
                    }


                Button(action: {
                    if !currentMessage.isEmpty {
                        chatViewModel.sendMessage(currentMessage)
                        currentMessage = ""
                    }
                }) {
                    Text("Send")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color.clear)
        .navigationTitle("Plan a New Trip (AI)")
    }
}

#Preview {
    AIAssistantView()
}
