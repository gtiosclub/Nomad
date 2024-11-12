import SwiftUI

struct AIAssistantView: View {
    @ObservedObject var vm: UserViewModel
    @StateObject var aiViewModel = AIAssistantViewModel()
    @ObservedObject var chatViewModel: ChatViewModel
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isMicrophone = false
    @State private var currentMessage: String = ""
    @State private var dotCount = 1
    @State private var isAdded: Bool = false //detect the add stop for changing style
    @State private var currentTabIndex: Int = 0 // Track the current tab index
    let timer = Timer.publish(every:0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            // Header
            if let trip = vm.current_trip {
                RoutePreviewView(vm: vm, trip: Binding.constant(trip), currentStopLocation: Binding.constant(nil))
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
                                
                                AtlasMessage(content: message.content, id: message.id)
                                
                                Spacer()
                            } else {
                                Spacer()
                                HStack {
                                    Text(message.content)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                        .frame(maxWidth: 270, alignment: .trailing)
                                    
                                    ZStack {
                                        Circle()
                                            .foregroundColor(Color.white)
                                            .frame(width: 30, height: 30) // Adjust size as needed
                                            .overlay(
                                                Circle()
                                                    .stroke(Color.black, lineWidth: 1) // Adds a black outline with a width of 2
                                            )
                                        
                                        // Image on top of the circle
                                        Image(systemName: "person")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    if chatViewModel.isQuerying{
                        //Detect if the ai is loading
                        HStack {
                            Image("AtlasIcon")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 35, height: 35)
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
            
            if !chatViewModel.pois.isEmpty {
                TabView {
                    ForEach(chatViewModel.pois) { poi in
                        POIDetailView(name: poi.name, address: poi.address, distance: poi.distance, phoneNumber: poi.phoneNumber, image: poi.image, rating: poi.rating, price: poi.price, time: poi.time)
                            .frame(width: 400, height: 120) // Adjust width and height as needed
                            .padding(.horizontal, 5) // Adds padding at the top and bottom
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 180)  // Adjust to fit the padding and content
                VStack {
                            Button(action: {
                                isAdded = true // Set state to true after button click
                                //add all the tabs
                                ForEach(chatViewModel.pois) { poi in
                                    vm.addStop(stop: poi)
                                }
                                
                                    // Reset to "Add Stop" after 2 seconds
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                        isAdded = false
                                    }
                                
                            }) {
                                Text(isAdded ? "Stop Added" : "Add Stop")
                                    .padding()
                                    .cornerRadius(10)
                                    .buttonStyle(.bordered)
                            }
                        }
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
    AIAssistantView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")), chatViewModel: ChatViewModel())
}



struct AtlasMessage: View {
    let content: String
    let id: UUID
    
    var body: some View {
        HStack {
            Image("AtlasIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 35, height: 35)
            
            Text(content)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 1)
                        .fill(Color.gray.opacity(0.2))
                )
                .frame(maxWidth: 270, alignment: .leading)
                .id(id)
        }

    }
}
