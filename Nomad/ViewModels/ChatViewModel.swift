//
//  ChatViewModel.swift
//  Nomad
//
//  Created by Connor on 10/29/24.
//

import Foundation

class ChatViewModel: ObservableObject {
    private var aiViewModel = AIAssistantViewModel()
    @Published var messages: [Message] = [
        Message(content: "Hi! I'm Atlas, your AI assistant", sender: "AI")
    ]
    
    @Published var pois: [POIDetail] = []
    @Published var latestAIResponse: String?
    @Published var isQuerying = false

    func sendMessage(_ content: String, vm: UserViewModel) {
        let newMessage = Message(content: content, sender: "User")
        messages.append(newMessage)
        isQuerying = true
        Task {
            defer { DispatchQueue.main.async { self.isQuerying = false }}
            if let pois = await self.aiViewModel.getPOIDetails(query: content, vm: vm) {
                DispatchQueue.main.async {
                    let aiMessage = Message(content: self.aiViewModel.atlasResponse, sender: "AI")
                    self.pois = pois
                    self.latestAIResponse = "Response"
                    self.messages.append(aiMessage)
                }
            } else {
                DispatchQueue.main.async {
                    let errorMessage = Message(content: "Sorry, I couldn't find any POIs", sender: "AI")
                    self.messages.append(errorMessage)
                    self.latestAIResponse = "Sorry, I couldn't find any restaurants"
                }
            }
        }
    }

    // New Chat Function
    func startNewChat() {
        messages = [
            Message(content: "Hi! I'm Atlas, your AI assistant", sender: "AI")
        ]
        pois.removeAll()
        latestAIResponse = nil
    }
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let sender: String
}

struct POIDetail: Identifiable {
    var id = UUID()
    var name: String
    var address: String
    var distance: String
    var phoneNumber: String
    var rating: String
    var price: String
    var image: String

    static let null = POIDetail(
        name: "Unavailable",
        address: "Unavailable",
        distance: "Unavailable",
        phoneNumber: "Unavailable",
        rating: "Unavailable",
        price: "Unavailable",
        image: ""
    )
}
