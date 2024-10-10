//
//  AIAssistantView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let sender: String
}

class ChatViewModel: ObservableObject {
    @ObservedObject private var aiViewModel = AIAssistantViewModel()
    @Published var messages: [Message] = [
        Message(content: "Hi! I'm Atlas, your AI assistant", sender: "AI")
    ]
    
    func sendMessage(_ content: String) {
        let newMessage = Message(content: content, sender: "User")
        messages.append(newMessage)
        
        // Simulate AI response asynchronously
        Task {
            // Call your Yelp-related function
            if let aiResponse = await aiViewModel.converseAndGetInfoFromYelp(query: content) {
                DispatchQueue.main.async {
                    let aiMessage = Message(content: aiResponse, sender: "AI")
                    self.messages.append(aiMessage)
                }
            } else {
                DispatchQueue.main.async {
                    let errorMessage = Message(content: "Sorry, I couldn't find any restaurants", sender: "AI")
                    self.messages.append(errorMessage)
                }
            }
        }
    }
}

struct AIAssistantView: View {
    @StateObject var aiViewModel = AIAssistantViewModel()
    @StateObject private var viewModel = ChatViewModel()
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
            
            List(viewModel.messages) { message in
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
                        viewModel.sendMessage(currentMessage)
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
