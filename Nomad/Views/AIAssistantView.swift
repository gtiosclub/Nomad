//
//  AIAssistantView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI
import AVFoundation

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let sender: String
}

class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = [
        Message(content: "Hi! I'm your AI assistant", sender: "AI")
    ]
    
    func sendMessage(_ content: String) {
        let newMessage = Message(content: content, sender: "User")
        messages.append(newMessage)
        
        // Simulate an AI response
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let aiResponse = Message(content: "Where would you like to go?", sender: "AI")
            self.messages.append(aiResponse)
        }
    }
}

struct AIAssistantView: View {
    // Connect the ViewModel to the View
    @StateObject private var viewModel = ChatViewModel()
    @State private var currentMessage: String = ""
    @StateObject private var speechRecognizer = SpeechRecognizer()

    var body: some View {
        VStack {
            HStack{
                Text("Let's plan your new trip")
                    .font(.title2)
                    .padding()
                Spacer()
            }
            
            // Chat message list
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
            
            // Input field and send button
            HStack {
                Button(action: {
                    
                }) {
                    Image(systemName: "microphone.fill"  )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .foregroundColor(.black)
                        //.background(Color.black)
                }
                TextField("Ask me anything...", text: $currentMessage)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .frame(minHeight: 40)

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
    
    private func startScrum() {
        //speechRecognizer.resetTranscript()
        //speechRecognizer.startTranscribing()
    }
    
    private func endScrum() {
        //speechRecognizer.stopTranscribing()
        //let newHistory = VoiceInput()
        //scrum.history.insert(newHistory, at: 0)
    }
}

#Preview {
    AIAssistantView()
}
