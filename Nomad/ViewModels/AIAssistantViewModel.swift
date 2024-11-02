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
    var yelpAPIKey = "<PUT API KEY HERE>"
    var gasPricesAPIKey = "<PUT GAS KEY HERE>"
    
    //used as context in chat so Atlas knows the last thing the user asked
    var currentLocationQuery: LocationInfo = LocationInfo(locationType: "", locationInformation: "", distance: 0.0, time: 0.0, price: "1,2,3,4", location: "", preferences: [])
    
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
    //used to summarize the user's location request
    struct LocationInfo: Codable, Equatable {
        let locationType: String
        let locationInformation: String
        let distance: Double
        let time: Double
        let price: String
        let location: String
        let preferences: [String]
    }

    
    
    
    init()  {
        fetchAPIKeys()
    }
    
    /*----------------------------------------------------
     Miscellaneous
     -----------------------------------------------------
     */
    
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
    
    //-------------------------------------------------
    
    /*----------------------------------------------------
     Parent Function
     -----------------------------------------------------
     */
    
    
    func getPOIDetails(query: String, vm: UserViewModel) async -> [POIDetail]? {
        let jsonString = await queryChatGPT(query: query) ?? ""
        let yelpInfo = await queryYelpWithjSONString(jsonString: jsonString, userVM: vm) ?? "!!!Failed!!!"
        print(yelpInfo)
        
        guard let businessResponse = parseGetBusinessesIntoModel(yelpInfo: yelpInfo) else {
            return [POIDetail.null]
        }
        
        print(businessResponse)
        
        // Collect information for the first three businesses (or fewer if less are available)
        var businessDetails: [(name: String, address: String, price: String, rating: Double, phoneNumber: String)] = []
        for i in 0..<min(3, businessResponse.businesses.count) {
            let business = businessResponse.businesses[i]
            let name = business.name
            let address = business.location.address1
            let price = business.price ?? ""
            let rating = business.rating ?? -1
            let phoneNumber = business.phone
            businessDetails.append((name, address, price, rating, phoneNumber))
        }
        
        // Collect POI details for the first three businesses (or fewer if less are available)
        let poiDetails = (0..<min(3, businessResponse.businesses.count)).compactMap { i -> POIDetail? in
            let business = businessResponse.businesses[i]
            return POIDetail(
                name: business.name,
                address: business.location.address1,
                distance: "",  // Assuming distance will be calculated or provided elsewhere
                phoneNumber: business.phone,
                rating: "\(business.rating ?? -1)",
                price: business.price ?? ""
            )
        }
        
        return poiDetails
    }

     //-------------------------------------------------
    
    /*----------------------------------------------------
     Helper Methods
     -----------------------------------------------------
     */
    
    //interacts GPT and returns a JSON representing the information that the user provided in their query
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
    
    //First converts the GPT JSON into a struct that is then parsed
    //The parsed information is used as parameters to call Yelp API
    //The function returns a JSON consisting of all the stops that fit the user's criteria
    func queryYelpWithjSONString(jsonString: String, userVM: UserViewModel) async -> String? {
        guard let locationInfo = convertStringToStruct(jsonString: jsonString) else {
            return "Error: Unable to parse JSON String"
        }
        currentLocationQuery = locationInfo
        let locationType = locationInfo.locationType
        let locationInformation = locationInfo.locationInformation
        let distance = locationInfo.distance
        let location = locationInfo.location
        let time = locationInfo.time
        let price = locationInfo.price
        let preferences = locationInfo.preferences.joined(separator: ", ")
        
        if(time != -1 && location == "MyLocation") {
            var sampleRoute = await MapManager.manager.getExampleRoute()!
            
            var route = userVM.current_trip?.route
            
            var coords = MapManager.manager.getFutureLocation(time: time, route: route ?? sampleRoute)
            
            guard let businessInformation = await fetchSpecificBusinesses(locationType: (locationInformation == "") ? locationType : locationInformation, distance: distance, price: price, location: "UseCoords", preferences: preferences, latitude: coords?.latitude ?? 0, longitutde: coords?.longitude ?? 0) else {
                return "Error: Unable to access YELP API"
            }
            return businessInformation
            
        } else {
            guard let businessInformation = await fetchSpecificBusinesses(locationType: (locationInformation == "") ? locationType : locationInformation, distance: distance, price: price, location: location, preferences: preferences, latitude: 0.0, longitutde: 0.0) else {
                return "Error: Unable to access YELP API"
            }
            return businessInformation
        }
    }
    
    //This function calls Yelp with the specified parameters and returns the Yelp APIs JSON
    func fetchSpecificBusinesses(locationType: String, distance: Double, price: String, location: String, preferences: String, latitude: Double, longitutde: Double) async -> String? {
        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "term", value: "\(preferences)  \(locationType)"),
            URLQueryItem(name: "price", value: price),
            URLQueryItem(name: "radius", value: "\(Int(distance * 1609))"), //Because the parameter takes in meters, we convert miles to meters (1 mile = 1608.34 meters)
            URLQueryItem(name: "limit", value: "3"),
        ]
        if(location == "UseCoords") {
            queryItems.append(URLQueryItem(name: "latitude", value: String(latitude)))
            queryItems.append(URLQueryItem(name: "longitude", value: String(longitutde)))
        } else {
            queryItems.append(URLQueryItem(name: "location", value: location))
        }
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
    
    func parseGetBusinessesIntoModel(yelpInfo: String) -> BusinessResponse? {
        let jsonData = yelpInfo.data(using: .utf8)! // Convert the string to Data
        
        do {
            // Decode the JSON data into a YelpLocation instance
            let decoder = JSONDecoder()
            let businessesResponse = try decoder.decode(BusinessResponse.self, from: jsonData)
            print("parseGetBusinessesIntoModel \(businessesResponse)")
            return businessesResponse
        } catch {
            print("Error decoding JSON (parseGetBusinessesIntoModel): \(error)")
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
    //-------------------------------------------------
    

    
    // Note: this is for text to speech functionality
    // func speak(text: String) {
    //   let utterance = AVSpeechUtterance(string: text)
    //    utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
    //   utterance.rate = 0.5
    
    //   speechSynthesizer.speak(utterance)
    //}
}
