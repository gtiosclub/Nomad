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
    
    func sendMessage(_ content: String, vm: UserViewModel) {
        let newMessage = Message(content: content, sender: "User")
        messages.append(newMessage)
        
        // Now call getPOIDetails to fetch POIs based on the user query
        Task {
            if let pois = await self.aiViewModel.getPOIDetails(query: content, vm: vm) {
                DispatchQueue.main.async {
                    let aiMessage = Message(content: "Here are some locations I've found for you!", sender: "AI")
                    self.pois = pois  // Update pois with fetched data
                    self.latestAIResponse = "Response"
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
    
    //For Testing the Horizontal Scroll View
//    @Published var pois: [POIDetail] = [
//        POIDetail(name: "Speedway", address: "901 Gas Station Avenue, Duluth GA", distance: "in 30 mi"),
//        POIDetail(name: "Shell", address: "123 Main Street, Atlanta GA", distance: "in 40 mi"),
//        POIDetail(name: "BP", address: "456 Elm Street, Lawrenceville GA", distance: "in 20 mi")
//    ]
    // Example function to generate sample POIs (you would use real data here)
    func generateSamplePOIs() -> [POIDetail] {
        return [
            POIDetail(name: "Speedway", address: "901 Gas Station Avenue, Duluth GA", distance: "in 30 mi", phoneNumber: "4045949429", rating: "3.3/5", price: "$"),
            POIDetail(name: "Shell", address: "123 Main Street, Atlanta GA", distance: "in 40 mi", phoneNumber: "4045949429", rating: "5/5", price: "$$$"),
            POIDetail(name: "BP", address: "456 Elm Street, Lawrenceville GA", distance: "in 20 mi", phoneNumber: "4045949429", rating: "4/5", price: "$$")
        ]
    }
}

struct Message: Identifiable {
    let id = UUID()
    let content: String
    let sender: String
}


// Add a model for POI details
struct POIDetail: Identifiable {
    var id = UUID()
    var name: String
    var address: String
    var distance: String
    var phoneNumber: String
    var rating: String
    var price: String
    
    // Static property for a null POIDetail instance
    static let null = POIDetail(
        name: "Unavailable",
        address: "Unavailable",
        distance: "Unavailable",
        phoneNumber: "Unavailable",
        rating: "Unavailable",
        price: "Unavailable"
    )
}

