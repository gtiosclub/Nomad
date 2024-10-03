//
//  AIAssistantViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import ChatGPTSwift

class AIAssistantViewModel: ObservableObject {
    let openAIAPIKey = ChatGPTAPI(apiKey: "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")
    let yelpAPIKey = "<PUT API KEY HERE>"
    let jsonResponseFormat = Components.Schemas.CreateChatCompletionRequest.response_formatPayload(_type: .json_object) // ensure that query returns json object
    let gptModel = ChatGPTModel(rawValue: "gpt-4o")

    
    func fetchBusinesses() async {
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
        request.addValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print(String(decoding: data, as: UTF8.self))
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
  
    func getChatGPT() async -> (String)  {
        let question:String = "where is Atlanta?"
        var result = ""
        do {
            let response = try await openAIAPIKey.sendMessage(
                text: question)
            return response
        } catch {
            print(error.localizedDescription)
        }
        return ""
    }
    
    func getJsonOutput(query: String) async -> String? {
        do {
            let response = try await openAIAPIKey.sendMessage(
                text: "Only return a JSON Object" + query,
                model: gptModel!,
                responseFormat: jsonResponseFormat)
            return response
        } catch {
            return "Send OpenAI Query Error: \(error.localizedDescription)"
        }
    }
    
    func getRestaurants(query: String) async -> String? {
        do {
            let response = try await openAIAPIKey.sendMessage(
                text: """
                    I will give you a question/statement. From this statement, extract the location type and distance I am looking for and put it in this JSON format:
                    {
                    locationType: <Restaurant/GasStation/Hotel/RestStop/Point of Interest/Activity>
                    distance: <Int>
                    location: <String>
                    }
                    
                    Here is the statement: \(query)
                """,
                model: gptModel!,
                responseFormat: jsonResponseFormat)
            return response
        } catch {
            return "Send OpenAI Query Error: \(error.localizedDescription)"
        }
    }
}
