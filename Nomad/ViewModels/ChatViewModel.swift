//
//  ChatViewModel.swift
//  Nomad
//
//  Created by Connor on 10/29/24.
//
import Foundation

class ChatViewModel: ObservableObject {
    var aiViewModel = AIAssistantViewModel()
    @Published var messages: [Message] = [
        Message(content: "Hi! I'm Atlas, your AI assistant", sender: "AI")
    ]
    
    @Published var pois: [POIDetail] = []
    @Published var latestAIResponse: String?
    @Published var isQuerying = false //the additional global variable for detecting if the gpt api is calling or not
    
    func sendMessage(_ content: String, vm: UserViewModel) {
        let newMessage = Message(content: content, sender: "User")
        messages.append(newMessage)
        isQuerying = true //before calling the API
        // Now call getPOIDetails to fetch POIs based on the user query
        Task {
            defer { DispatchQueue.main.async {self.isQuerying = false}}
            if let pois = await self.aiViewModel.getPOIDetails(query: content, vm: vm) {
                DispatchQueue.main.async {
                    let aiMessage = Message(content: self.aiViewModel.atlasResponse, sender: "AI")
                    self.pois = pois  // Update pois with fetched data
                    self.latestAIResponse = aiMessage.content
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
    
    //For Testing the Horizontal Scroll View
//    @Published var pois: [POIDetail] = [
//        POIDetail(name: "Speedway", address: "901 Gas Station Avenue, Duluth GA", distance: "in 30 mi"),
//        POIDetail(name: "Shell", address: "123 Main Street, Atlanta GA", distance: "in 40 mi"),
//        POIDetail(name: "BP", address: "456 Elm Street, Lawrenceville GA", distance: "in 20 mi")
//    ]
    // Example function to generate sample POIs (you would use real data here)
//    func generateSamplePOIs() -> [POIDetail] {
//        return [
//            POIDetail(name: "Speedway", address: "901 Gas Station Avenue, Duluth GA", distance: 15, phoneNumber: "4045949429", rating: 3.3, price: "$", image: "", time: 3.0),
//            POIDetail(name: "Shell", address: "123 Main Street, Atlanta GA", distance: 5, phoneNumber: "4045949429", rating: 3.2, price: "$$$", image: "", time: 4.1),
//            POIDetail(name: "BP", address: "456 Elm Street, Lawrenceville GA", distance: 7, phoneNumber: "4045949429", rating: 5, price: "$$", image: "", time: 7.2)
//        ]
//    }
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
    var distance: Double
    var phoneNumber: String
    var rating: Double
    var price: String
    var image: String
    var time: Double
    var latitude: Double
    var longitude: Double
    var city: String
    
    // Static property for a null POIDetail instance
    static let null = POIDetail(
        name: "Unavailable",
        address: "Unavailable",
        distance: 5.4,
        phoneNumber: "Unavailable",
        rating: 0.0,
        price: "Unavailable",
        image: "",
        time: 0.0,
        latitude: 45.0,
        longitude: 34.0,
        city: ""
    )
}

