import SwiftUI
import Combine

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
       VStack(spacing: 0){
           HeaderView(vm: vm, cvm: chatViewModel)
           ZStack(alignment: .topTrailing) {
               ChatMessagesView(chatViewModel: chatViewModel, dotCount: dotCount, timer: timer)
               
               Button(action: {
                   chatViewModel.startNewChat()
               }) {
                   
               }
               .padding(.top) // Adjust this to control distance from the top
           }
           
           
           if !chatViewModel.pois.isEmpty {
               POICarouselView(chatViewModel: chatViewModel, vm: vm, aiViewModel: aiViewModel, addStop: addStop)
                   .padding(.bottom, 0)
           }
           
           HStack {
               Button(action: {
                   // Microphone action if necessary
                   if isMicrophone {
                       speechRecognizer.stopTranscribing()
                       let transcript = speechRecognizer.transcript
                       
                       if !transcript.isEmpty {
                           chatViewModel.sendMessage(transcript, vm: vm)
                           currentMessage = ""
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
                       .background(Color.nomadDarkBlue)
                       .foregroundColor(.white)
                       .cornerRadius(10)
               }
           }
           .padding()
           .onDisappear {
               speechRecognizer.stopTranscribing()
               speechRecognizer.resetTranscript()
           }
       }
       .background(Color.clear)
    }
    func addStop(_ stop: any POI) {
            Task {
                await vm.addStop(stop: stop)
                
                guard let start_loc = vm.current_trip?.getStartLocation() else { return }
                guard let end_loc = vm.current_trip?.getEndLocation() else { return }
                guard let all_stops = vm.current_trip?.getStops() else { return }
                
                var all_pois: [any POI] = []
                all_pois.append(start_loc)
                all_pois.append(contentsOf: all_stops)
                all_pois.append(end_loc)
                
                if let newRoutes = await MapManager.manager.generateRoute(pois: all_pois) {
                    vm.setTripRoute(route: newRoutes[0])
                }
            }
        }
}

#Preview {
    AIAssistantView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")), chatViewModel: ChatViewModel())
}

struct ChatMessagesView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    @State var dotCount: Int
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    
    var body: some View {
        ScrollViewReader { reader in
            ScrollView {
                ZStack(alignment: .topTrailing) {
                    Button(action: {
                           chatViewModel.startNewChat()
                       }) {
                           Image(systemName: "arrow.circlepath")
                               .resizable()
                               .frame(width: 35, height: 30)
                               .padding(5)
                       }
                    
                    
                    VStack(spacing: 3) {
                        ForEach(chatViewModel.messages) { message in
                            HStack {
                                if message.sender == "AI" {
                                    AtlasMessage(content: message.content, id: message.id)
                                    Spacer()
                                } else {
                                    Spacer()
                                    UserMessageView(content: message.content)
                                }
                            }
                            .padding(.horizontal)
                        }.padding(.top)
                        
                        if chatViewModel.isQuerying {
                            HStack {
                                Image("AtlasIcon")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 35, height: 35)
                                
                                Text(String(repeating: ".", count: dotCount))
                                    .padding()
                                    .onReceive(timer) { _ in
                                        self.dotCount = (dotCount % 3) + 1
                                    }
                                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                                    .frame(maxWidth: 270, alignment: .leading)
                            }
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }
            .onChange(of: chatViewModel.messages.count) { _ in
                if let lastMessage = chatViewModel.messages.last {
                    reader.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
        }
    }
}

struct UserMessageView: View {
    let content: String
    
    var body: some View {
        HStack {
            Text(content)
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 1))
                .frame(maxWidth: 270, alignment: .trailing)
            
            ZStack {
                Circle()
                    .foregroundColor(Color.white)
                    .frame(width: 30, height: 30)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 1)
                    )
                
                Image(systemName: "person")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
            }
        }
    }
}

struct HeaderView: View {
    var vm: UserViewModel
    var cvm: ChatViewModel
    
    var body: some View {
        if let trip = vm.current_trip {
            RoutePreviewAtlasView(vm: vm, cvm: cvm, trip: Binding.constant(trip), currentStopLocation: Binding.constant(nil))
                .frame(minHeight: 200.0)
        } else {
            Text("No current trip available")
                .foregroundColor(.red)
        }
    }
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
                        .fill(Color.nomadLightBlue)
                )
                .frame(maxWidth: 270, alignment: .leading)
                .id(id)
        }

    }
}


struct POICarouselView: View {
    @ObservedObject var chatViewModel: ChatViewModel
    var vm: UserViewModel
    var aiViewModel: AIAssistantViewModel
    
    var addStop: (any POI) -> Void
    
    var body: some View {
        TabView {
            ForEach(chatViewModel.pois) { poi in
                POIDetailView(name: poi.name, address: poi.address, distance: poi.distance, phoneNumber: poi.phoneNumber, image: poi.image, rating: poi.rating, price: poi.price, time: poi.time, latitude: poi.latitude, longitude: poi.longitude, city: poi.city, vm: vm, aiVM: aiViewModel, addStop: addStop)
                    .padding(.horizontal, 5)
                    .padding(.bottom, 35)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .frame(height: 200)
    }
}


