//
//  AIAssistantViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import ChatGPTSwift

class AIAssistantViewModel: ObservableObject {
    let openAIAPIKey = ChatGPTAPI(apiKey: "<API KEY HERE>") //<API KEY HERE>"
    let yelpAPIKey = "<API KEY HERE>" //<API KEY HERE>"
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
    
    func queryChatGPT(query: String) async -> String? {
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
    
    
    
    
    
    
    
    
    
    // Helper function that will take in a JSON formatted String and turn it into an accessible Swift Data Structure
    func convertStringToStruct(jsonString: String) -> LocationInfo? {
        let jsonData = jsonString.data(using: .utf8)! // Convert the string to Data
        
        do {
            // Decode the JSON data into a YelpLocation instance
            let decoder = JSONDecoder()
            let location = try decoder.decode(LocationInfo.self, from: jsonData)
            return location
        } catch {
            print("Error decoding JSON: \(error)")
            return LocationInfo(locationType: "", distance: -1, location: "")
        }
    }
    
    struct LocationInfo: Codable, Equatable {
        let locationType: String
        let distance: Int
        let location: String
    }
    
    func fetchSpecificBusinesses(locationType: String, distance: Int, location: String) async -> String? {
        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "location", value: location),
            URLQueryItem(name: "term", value: locationType),
            URLQueryItem(name: "radius", value: "\(distance * 1609)"), //Because the parameter takes in meters, we convert miles to meters (1 mile = 1608.34 meters)
            URLQueryItem(name: "limit", value: "2"),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.addValue("Bearer \(yelpAPIKey)", forHTTPHeaderField: "Authorization")
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            return String(decoding: data, as: UTF8.self)
        } catch {
            return "Error fetching data: \(error.localizedDescription)"
        }
    }
    
    
    func queryYelp(jsonString: String) async -> String? {
        guard let locationInfo = convertStringToStruct(jsonString: jsonString) else {
            return "Error: Unable to parse JSON String"
        }
        let locationType = locationInfo.locationType
        let distance = locationInfo.distance
        let location = locationInfo.location
        guard let businessInformation = await fetchSpecificBusinesses(locationType: locationType, distance: distance, location: location) else {
            return "Error: Unable to access YELP API"
        }
        return businessInformation
    }
    
    
    
    
    
    
    
}
