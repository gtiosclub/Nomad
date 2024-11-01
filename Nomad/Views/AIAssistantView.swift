import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let sender: String
}

class ChatViewModel: ObservableObject {
    @ObservedObject private var aiViewModel = AIAssistantViewModel()
    @Published var messages: [Message] = [
        Message(content: "Let me help you find a stop!", sender: "AI")
    ]
    
    @Published var latestAIResponse: String?
    
    func sendMessage(_ content: String, vm: UserViewModel) {
        let newMessage = Message(content: content, sender: "User")
        messages.append(newMessage)
        
        // Simulate AI response asynchronously
        Task {
            if let aiResponse = await aiViewModel.converseAndGetInfoFromYelp(query: content, userVM: vm) {
                DispatchQueue.main.async {
                    let aiMessage = Message(content: aiResponse, sender: "AI")
                    self.messages.append(aiMessage)
                    self.latestAIResponse = aiResponse
                }
            } else {
                DispatchQueue.main.async {
                    let errorMessage = Message(content: "Sorry, I couldn't find any restaurants", sender: "AI")
                    self.messages.append(errorMessage)
                    self.latestAIResponse = "Sorry, I couldn't find any restaurants"
                }
            }
        }
    }
}

struct AIAssistantView: View {
    @ObservedObject var vm: UserViewModel
    @StateObject var aiViewModel = AIAssistantViewModel()
    @StateObject private var viewModel = ChatViewModel()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isMicrophone = false
    @State private var currentMessage: String = ""

    var body: some View {
        VStack {
            // Header
            Spacer().frame(height: 100)

            // Chat messages
            ScrollView {
                ForEach(viewModel.messages) { message in
                    HStack {
                        if message.sender == "AI" {
                            HStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.gray) // Placeholder for AI avatar
                                Text(message.content)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                    .frame(maxWidth: 270, alignment: .leading)
                            }
                            Spacer()
                        } else {
                            Spacer()
                            HStack {
                                Text(message.content)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                    .frame(maxWidth: 270, alignment: .trailing)
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue) // Placeholder for User avatar
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color.clear)

            // Bottom input field
            HStack {
                Button(action: {
                    // Microphone action if necessary
                    if isMicrophone {
                        speechRecognizer.stopTranscribing()
                        let transcript = speechRecognizer.transcript
                        
                        if !transcript.isEmpty {
                            viewModel.sendMessage(transcript, vm: vm)
                            currentMessage = transcript
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
                        viewModel.sendMessage(currentMessage, vm: vm)
                        currentMessage = ""
                    }
                }) {
                    Image(systemName: "paperplane.fill")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
        .background(Color.clear)
    }
}

#Preview {
    AIAssistantView(vm: UserViewModel())
}
