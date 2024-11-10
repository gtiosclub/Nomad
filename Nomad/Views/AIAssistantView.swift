import SwiftUI

struct AIAssistantView: View {
    @ObservedObject var vm: UserViewModel
    @StateObject var aiViewModel = AIAssistantViewModel()
    @ObservedObject var chatViewModel: ChatViewModel
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isMicrophone = false
    @State private var currentMessage: String = ""
    @State private var dotCount = 1
    let timer = Timer.publish(every:0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            // Header
            if let trip = vm.current_trip {
                RoutePreviewView(vm: vm, trip: Binding.constant(trip))
                    .frame(minHeight: 200.0)
            } else {
                Text("No current trip available")
                    .foregroundColor(.red)
            }

            // Chat messages
            ScrollViewReader { reader in
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
                                        .id(message.id)
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
                    if chatViewModel.isQuerying{
                        //Detect if the ai is loading
                        HStack {
                            Circle()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.gray) // Placeholder for AI avatar
                            Text(String(repeating: ".", count: dotCount))
                                .padding()
                                .onReceive(timer) { _ in
                                    dotCount = (dotCount % 3) + 1
                                }
                                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                .frame(maxWidth: 270, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                }
                .background(Color.clear)
                .padding(.bottom)
                .onChange(of: chatViewModel.messages.count) { _ in
                    if let lastMessage = chatViewModel.messages.last {
                        // Scroll to the latest message
                        reader.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
            
            // Horizontal scroll view for POIs
//            if !chatViewModel.pois.isEmpty {
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 20) {
//                        ForEach(chatViewModel.pois) { poi in
//                            POIDetailView(name: poi.name, address: poi.address, distance: poi.distance)
//                                .frame(width: 400) // Adjust width as necessary
//                        }
//                    }
//                    .padding(.horizontal)
//                }
//                .frame(height: 110)  // Adjust height as needed
//            }
            
            if !chatViewModel.pois.isEmpty {
                TabView {
                    ForEach(chatViewModel.pois) { poi in
                        POIDetailView(name: poi.name, address: poi.address, distance: poi.distance, image: poi.image)
                            .frame(width: 400, height: 120) // Adjust width and height as needed
                            .padding(.horizontal, 5) // Adds padding at the top and bottom
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 180)  // Adjust to fit the padding and content
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
                        dotCount = 1
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
    AIAssistantView(vm: UserViewModel(), chatViewModel: ChatViewModel())
}
