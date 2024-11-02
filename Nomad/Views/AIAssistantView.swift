import SwiftUI

struct AIAssistantView: View {
    @ObservedObject var vm: UserViewModel
    @StateObject var aiViewModel = AIAssistantViewModel()
    @StateObject private var chatViewModel = ChatViewModel()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isMicrophone = false
    @State private var currentMessage: String = ""
    

    var body: some View {
        VStack {
            // Header
            Spacer().frame(height: 100)

            // Chat messages
            ScrollView {
                ForEach(chatViewModel.messages) { message in
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
                            chatViewModel.sendMessage(transcript, vm: vm)
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
                        chatViewModel.sendMessage(currentMessage, vm: vm)
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
