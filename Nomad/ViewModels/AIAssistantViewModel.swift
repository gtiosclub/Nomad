//
//  AIAssistantViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import ChatGPTSwift

class AIAssistantViewModel: ObservableObject {
    
    
    func fetchBusinesses() async {
        let apiKey = "hpQdyXearQyP-ahpSeW2wDZvn-ljfmsGvN6RTKqo18I6R23ZB3dfbzAnEjvS8tWoPwyH9FFTGifdZ-n_qH80jbRuDbGb0dHu1qEPrLH-vqNq_d6TZdUaC_kZpwvqZnYx"
        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "location", value: "Atlanta"),
            URLQueryItem(name: "term", value: "gas"),
            URLQueryItem(name: "sort_by", value: "best_match"),
            URLQueryItem(name: "limit", value: "2"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print(String(decoding: data, as: UTF8.self))
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
  
    func getChatGPT() async -> (String)  {
        let apiKey = ChatGPTAPI(apiKey: "*Put api key*")
        
        let question:String = "where is Atlanta?"
        var result = ""
        do {
            let response = try await apiKey.sendMessage(text: question)
            return response
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
}
 
