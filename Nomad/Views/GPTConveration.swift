//
//  AIAssistantView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI
import ChatGPTSwift




var isOnceGPT = true;

class ChatController: ObservableObject {
    //created a list of messages where has isUser as bool
    //@published means the variables will keep updated concurrently
    @Published var messages: [Message] = [.init(content: "Hello", isUser: true), .init(content: "Hello", isUser: false)]
    //the gptkey to call the openai api
    let gptKey = ChatGPTAPI(apiKey:"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")
    //appending user message to the chatbox
    func sendNewMessage(content: String) async {
        let userMessage = Message(content: content, isUser: true)
        self.messages.append(userMessage)
       // let gptResponse = Message(content:await getaiReply(userString: userMessage), isUser: false)
        //self.messages.append(gptResponse)
        await getaiReply(userString: userMessage)
    }
    //function to get the ai response
    func getaiReply(userString: Message) async -> String{
        do {
            if(isOnceGPT) {
                //assign the response to the initial condition
                let response = try await gptKey.sendMessage(text: initialConditionSentence)
                DispatchQueue.main.async {
                    self.messages.append(Message(content: response, isUser: false))
                }
                isOnceGPT = false;
                
            }
            //calling the chatGPTSwift method "sendMessage" to get the response from gpt
            let response = try await gptKey.sendMessage(text: userString.content)
            DispatchQueue.main.async {
                self.messages.append(Message(content: response, isUser: false))
            }
            //return response
        } catch {
            print("Something went wrong when calling gpt api to get a response: , \(error.localizedDescription)")
        }
        return ""
    }
    
}

struct Message: Identifiable {
    var id: UUID = .init()
    var content: String
    var isUser: Bool
}





struct GPTConversation: View {
    @StateObject var chatController: ChatController = .init()
    @State var string: String = ""
    //let newTrip = Trip(start_location: POI(), end_location: <#T##any POI#>)
    var body: some View {
        //Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        VStack{
            ScrollView {
                ForEach(chatController.messages) {
                    message in
                    MessageView(message: message)
                        .padding(5)
                }
            }
        }
        Divider()
        HStack {
            TextField("Message...", text:self.$string, axis: .vertical)
                .padding(EdgeInsets())
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            Button {
                //this is where frontend sending the content string into the api side when the button is click
                Task {
                    await self.chatController.sendNewMessage(content: string)
                    string = ""
                }
                
            } label: {
                Image(systemName: "paperplane")
            }
        }
        .padding()
        
    }
}


struct MessageView: View {
    var message: Message
    var body: some View {
        Group {
            if message.isUser {
                // user side
                HStack {
                    Spacer()
                    Text(message.content)
                        .padding()
                        .background(Color.gray)
                        .foregroundColor(Color.white)
                        //.clipShape(Capsule())
                }
            } else {
                //the gpt side
                HStack {
                    Text(message.content)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(Color.white)
                        //.clipShape(Capsule())
                    Spacer()
                }
            }
        }
    }
}




#Preview {
    AIAssistantView()
}
