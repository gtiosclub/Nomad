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
        let apiKey = "Use yelp key"
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
        let apiKey = ChatGPTAPI(apiKey: "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")
        
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
    
    func getGasPrices(stateCode: String) async -> Double? {
        let headers = [
            "content-type": "application/json",
            "authorization": "*Gas Prices API*"
        ]

        guard let url = URL(string: "https://api.collectapi.com/gasPrice/stateUsaPrice?state=\(stateCode)") else {
            return nil // Return nil if URL is invalid
        }

        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers

        let session = URLSession.shared

        do {
            let (data, response) = try await session.data(for: request)
            
            // Check if the response is HTTP URL response and handle status codes
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    print("HTTP error: \(httpResponse.statusCode)")
                    return nil // Handle non-success HTTP status codes
                }
            }
            // Convert data to String
            
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let result = json["result"] as? [String: Any],
               let state = result["state"] as? [String: Any],
               let gasolinePriceString = state["gasoline"] as? String,
                let gasolinePrice = Double(gasolinePriceString) {
                return gasolinePrice // Return the gasoline price
            } else {
                print("Error parsing JSON")
                return nil
            }
        } catch {
            print("Error during data task: \(error)")
            return nil
        }
    }
}
 
