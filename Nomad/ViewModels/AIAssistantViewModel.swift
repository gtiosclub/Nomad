//
//  AIAssistantViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import ChatGPTSwift

class AIAssistantViewModel: ObservableObject {
    var openAIAPIKey = ChatGPTAPI(apiKey: "<PUT API KEY HERE>")
    var currentLocationQuery: LocationInfo = LocationInfo(locationType: "", locationInformation: "", distance: 0.0, time: 0.0, price: "1,2,3,4", location: "", preferences: [])
    var yelpAPIKey = "<PUT API KEY HERE>"
    var gasPricesAPIKey = "<PUT GAS KEY HERE>"
    let jsonResponseFormat = Components.Schemas.CreateChatCompletionRequest.response_formatPayload(_type: .json_object) // ensure that query returns json object
    let gptModel = ChatGPTModel(rawValue: "gpt-4o")
    let FirebaseVM: FirebaseViewModel = FirebaseViewModel()
    
    let initialConditionSentence:String = """
    I have a Trip with properties
        stops: [POI]
        start_location: POI
        end_location: POI
        start_date: String
        end_date: String

    Keep asking me questions until you have information to fill out the Trip. Do not mention the actual variable names.

    """
    
    init()  {
        fetchAPIKeys()
    }
    
    private func fetchAPIKeys() {
        Task {
            do {
                let apimap = try await FirebaseVM.getAPIKeys()
                
                self.openAIAPIKey = ChatGPTAPI(apiKey: apimap["OPENAI"] ?? "Error")
                self.yelpAPIKey = apimap["YELP"] ?? "Error"
                self.gasPricesAPIKey = apimap["GASPRICES"] ?? "Error"

            } catch {
                print("Failed to fetch API keys: \(error)")
            }
        }
    }
    
    
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
                    I will give you a question/statement. From this statement, extract the following information and put it in this JSON format. Price is default "1,2,3,4", and should only include upper or lower ranges based on user price preference. If the user refers to their own location or route, set location field to "MyLocation". If user does not mention time, set time to -1.
                    {
                    locationType: <Restaurant/Gas Station/Hotel/Rest Stop/Point of Interest/Activity>
                    locationInformation: <String>
                    distance: <Double>
                    time: <Double (in seconds)>
                    price: <1,2,3,4>
                    location: <String>
                    preferences: [String]
                    }
                    
                    Reuse information from past queries if not given by the user: \(currentLocationQuery). Here is the statement: \(query)
                """,
                model: gptModel!,
                responseFormat: jsonResponseFormat)
            
            print(response)
            
            return response
        } catch {
            return "Send OpenAI Query Error: \(error.localizedDescription)"
        }
    }
    
    func getGasPrices(stateCode: String) async -> Double? {
        let headers = [
            "content-type": "application/json",
            "authorization": gasPricesAPIKey
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
            print(location)
            
            return location
        } catch {
            print("Error decoding JSON: \(error)")
            return LocationInfo(locationType: "", locationInformation: "", distance: -1, time: 0.0, price: "1,2,3,4", location: "", preferences: [])
        }
    }
    
    struct LocationInfo: Codable, Equatable {
        let locationType: String
        let locationInformation: String
        let distance: Double
        let time: Double
        let price: String
        let location: String
        let preferences: [String]
    }
    
    func fetchSpecificBusinesses(locationType: String, distance: Double, price: String, location: String, preferences: String) async -> String? {
        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "location", value: location),
            URLQueryItem(name: "term", value: "\(preferences)  \(locationType)"),
            URLQueryItem(name: "price", value: price),
            URLQueryItem(name: "radius", value: "\(Int(distance * 1609))"), //Because the parameter takes in meters, we convert miles to meters (1 mile = 1608.34 meters)
            URLQueryItem(name: "limit", value: "1"),
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
    
    
    
    func queryYelpWithjSONString(jsonString: String) async -> String? {
        guard let locationInfo = convertStringToStruct(jsonString: jsonString) else {
            return "Error: Unable to parse JSON String"
        }
        let locationType = locationInfo.locationType
        let locationInformation = locationInfo.locationInformation
        let distance = locationInfo.distance
        let location = locationInfo.location
        let time = locationInfo.time
        
        let price = locationInfo.price
        let preferences = locationInfo.preferences.joined(separator: ", ")
        guard let businessInformation = await fetchSpecificBusinesses(locationType: (locationInformation == "") ? locationType : locationInformation, distance: distance, price: price, location: location, preferences: preferences) else {
            return "Error: Unable to access YELP API"
        }
        return businessInformation
    }
    
    func parseGetBusinessesIntoModel(yelpInfo: String) -> BusinessResponse? {
        let jsonData = yelpInfo.data(using: .utf8)! // Convert the string to Data
        
        do {
            // Decode the JSON data into a YelpLocation instance
            let decoder = JSONDecoder()
            let businessesResponse = try decoder.decode(BusinessResponse.self, from: jsonData)
            return businessesResponse
        } catch {
            print("Error decoding JSON: \(error)")
            return nil
        }
    }
    
    func formatResponseToUser(name: String, address: String, price: String, rating: Double, phoneNumber: String) async -> String? {
        do {
            let response = try await openAIAPIKey.sendMessage(
                text: """
                    I will give you data about a business. Give the data back to the user in a concise yet friendly manner. Ensure you write in complete sentences. Although I say I will give you data, it doesn't mean the data is valid. Use discretion on whether the data is valid, and if none of the data is valid, then say there are no restaurants in the area. Note that the price will be a symbol "$", and the number of dollar signs will be out of four. For example, $$$$ = most expensive. Rating is out of 5.0.
                
                    Here is the data: <<<Name: \(name), Address: \(address), Price: \(price), Rating: \(rating), Phone Number: \(phoneNumber)
                """,
                model: gptModel!)
            return response
        } catch {
            return "Send OpenAI Query Error: \(error.localizedDescription)"
        }
    }
    
    func converseAndGetInfoFromYelp(query: String) async -> String? {
        let jsonString = await queryChatGPT(query: query) ?? ""
        let yelpInfo = await queryYelpWithjSONString(jsonString: jsonString) ?? "!!!Failed!!!"
        print(yelpInfo)
        let businessResponse = parseGetBusinessesIntoModel(yelpInfo: yelpInfo)
        
        let name = businessResponse?.businesses.first?.name ?? ""
        let address = businessResponse?.businesses.first?.location.address1 ?? ""
        let price = businessResponse?.businesses.first?.price ?? ""
        let rating = businessResponse?.businesses.first?.rating ?? -1
        let phoneNumber = businessResponse?.businesses.first?.phone ?? ""
        
        let response = await formatResponseToUser(name: name, address: address, price: price, rating: rating, phoneNumber: phoneNumber)
        return response
    }
    
    // Note: this is for text to speech functionality
    // func speak(text: String) {
    //   let utterance = AVSpeechUtterance(string: text)
    //    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    //   utterance.rate = 0.5
    
    //   speechSynthesizer.speak(utterance)
    //}
}
