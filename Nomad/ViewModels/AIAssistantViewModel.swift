//
//  AIAssistantViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import ChatGPTSwift
import CoreLocation

class AIAssistantViewModel: ObservableObject {
    var openAIAPIKey = ChatGPTAPI(apiKey: "<PUT API KEY HERE>")
    var yelpAPIKey = "<PUT API KEY HERE>"
    var gasPricesAPIKey = "<PUT GAS KEY HERE>"
    @Published var atlasResponse = ""
    
    @Published var currentLocationType: String = "Restaurant"
    
    //used as context in chat so Atlas knows the last thing the user asked
    var currentLocationQuery: LocationInfo = LocationInfo(locationType: "", locationInformation: "", distance: 0.0, time: 0.0, price: "1,2,3,4", location: "", preferences: [], atlasResponse: "")
    var currentAtlasTrip: AtlasTrip = AtlasTrip(stops: [])
    
    let jsonResponseFormat = Components.Schemas.CreateChatCompletionRequest.response_formatPayload(_type: .json_object) // ensure that query returns json object
    let gptModel = ChatGPTModel(rawValue: "gpt-4o")
    
    let FirebaseVM: FirebaseViewModel = FirebaseViewModel.vm
    
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
        let atlasResponse: String?
    }

    struct AtlasTrip: Codable {
        var stops: [LocationInfo]
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
     Parent Functions
     -----------------------------------------------------
     */
    
    
    func getPOIDetails(query: String, vm: UserViewModel) async -> [POIDetail]? {
        let jsonString = await queryChatGPT(query: query) ?? ""
        let yelpInfo = await queryYelpWithjSONString(jsonString: jsonString, userVM: vm) ?? "!!!Failed!!!"
        print(yelpInfo)
        
        guard let businessResponse = parseGetBusinessesIntoModel(yelpInfo: yelpInfo) else {
            return [POIDetail.null]
        }
        
        if(businessResponse.businesses.isEmpty) {
            atlasResponse = "I couldn’t find any stops with the current criteria. Try broadening your search for more results."
        }
        
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
        var poiDetails: [POIDetail] = []

        for i in 0..<min(3, businessResponse.businesses.count) {
            let business = businessResponse.businesses[i]
            
            let coords = CLLocationCoordinate2D(latitude: business.coordinates.latitude, longitude: business.coordinates.longitude)
            
            var poiDetail: POIDetail
            // Use await to get routeAdditions asynchronously
            if let route = vm.current_trip?.route {
                let routeAdditions = await MapManager.manager.determineRouteAdditions(route: route, newStop: coords)
                
                print("route additions \(routeAdditions)")
                
                poiDetail = POIDetail(
                    name: business.name,
                    address: "\(business.location.address1), \(business.location.city), \(business.location.state) \(business.location.zipCode)",
                    distance: routeAdditions?.distanceAdded ?? 2.2,  // Placeholder for actual distance calculation
                    phoneNumber: business.phone,
                    rating: business.rating ?? 4.0,
                    price: business.price ?? "",
                    image: business.imageUrl ?? "",
                    time: (abs(routeAdditions?.timeAdded ?? 300) / 60.0),
                    latitude: business.coordinates.latitude,
                    longitude: business.coordinates.longitude,
                    city: business.location.city
                )
            } else {
                poiDetail = POIDetail(
                    name: business.name,
                    address: "\(business.location.address1), \(business.location.city), \(business.location.state) \(business.location.zipCode)",
                    distance: 2.2,  // Placeholder for actual distance calculation
                    phoneNumber: business.phone,
                    rating: business.rating ?? 4.0,
                    price: business.price ?? "",
                    image: business.imageUrl ?? "",
                    time: 300 / 60.0,
                    latitude: business.coordinates.latitude,
                    longitude: business.coordinates.longitude,
                    city: business.location.city
                    )
            }
            
            
            
            
            poiDetails.append(poiDetail)
        }
        
        return poiDetails
    }
    
    func generateTripWithAtlas(userVM: UserViewModel) async -> String {
        let expectedTravelTime = userVM.current_trip?.route?.route?.expectedTravelTime ?? 0.0
        let brainstormedStops = await gptGenerateStops(startTime: userVM.current_trip?.getStartTime() ?? "",
                                                       startLocation: userVM.current_trip?.getStartLocation().address ?? "",
                                                       endLocation: userVM.current_trip?.getEndLocation().address ?? "",
                                                       expectedTravelTime: String(expectedTravelTime)) ?? ""
        
        if let jsonData = brainstormedStops.data(using: .utf8) {
            do {
                let stopsData = try JSONDecoder().decode(AtlasTrip.self, from: jsonData)
                
                let totalStops = stopsData.stops.count
                var businessInformationResults: [String] = []
                
                // Create an array of async tasks for fetching businesses
                await withTaskGroup(of: (Int, String).self) { group in
                    for (index, locationInfo) in stopsData.stops.enumerated() {
                        group.addTask { [self] in
                            let locationType = locationInfo.locationType
                            let locationInformation = locationInfo.locationInformation
                            let distance = locationInfo.distance
                            let location = locationInfo.location
                            let time = locationInfo.time
                            let price = locationInfo.price
                            let preferences = locationInfo.preferences.joined(separator: ", ")
                            
                            var businessInformation: String = ""
                            
                            if time != -1 && location == "MyLocation" {
                                let coords = await getCoordsFromTime(time: time, userVM: userVM)
                                businessInformation = await fetchSpecificBusinesses(locationType: (locationInformation == "") ? locationType : locationInformation, distance: 2, price: price, location: "UseCoords", preferences: preferences, latitude: coords.latitude, longitutde: coords.longitude, limit: 1) ?? ""
                            } else {
                                businessInformation = await fetchSpecificBusinesses(locationType: (locationInformation == "") ? locationType : locationInformation, distance: distance, price: price, location: location, preferences: preferences, latitude: 0.0, longitutde: 0.0, limit: 1) ?? ""
                            }
                            
                            return (index, businessInformation)
                        }
                    }
                    
                    // Collect all results
                    for await (index, businessInformation) in group {
                        businessInformationResults.append(businessInformation)
                    }
                }
                
                // Process the results of all business fetches
                for (index, businessInformation) in businessInformationResults.enumerated() {
                    guard let businessResponse = parseGetBusinessesIntoModel(yelpInfo: businessInformation) else {
                        return ""
                    }
                    
                    if businessResponse.businesses.count > 0 {
                        let business = businessResponse.businesses[0]
                        let poi = GeneralLocation(address: "\(business.location.address1), \(business.location.city), \(business.location.state) \(business.location.zipCode)",
                                                  name: business.name,
                                                  latitude: business.coordinates.latitude,
                                                  longitude: business.coordinates.longitude)
                        await userVM.addStop(stop: poi)
                    }
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }
        return ""
    }
    
    /*----------------------------------------------------
     Helper Methods
     -----------------------------------------------------
     */
    
    func gptGenerateStops(startTime: String, startLocation: String, endLocation: String, expectedTravelTime: String) async -> String? {
        print("start time \(startTime)")
        print("start location \(startLocation)")
        print("end location \(endLocation)")
        print("expected travel time \(expectedTravelTime)")

        do {
            let response = try await openAIAPIKey.sendMessage(
                text: """
                   A road trip starts at \(startTime) from \(startLocation) and ends at \(endLocation), with an expected travel time of \(expectedTravelTime). Your task is to suggest stops for the trip. Number of activities/shopping stops is limited to one per day, total stops is max 3 per day, and that the travel time to each stop does not exceed the expected travel time. The location should default to "MyLocation" unless a city or landmark is mentioned. Location information should be a blank String unless locationType is "Activity". The price range should be adjusted based on user preferences once provided. Price range (defaults to "1,2,3,4" but should be adjusted based on user preferences). Each stop should be a JSON object with the following fields:
                    { stops: [{
                    locationType: <Restaurant/Gas Station/Hotel/Rest Stop/Activity/Shopping>
                    locationInformation: <String> (e.g., "Museum" for Activity, or specific name)
                    distance: <Double>
                    time: <Double (in seconds)>
                    price: <String> (Default is "1,2,3,4")
                    location: <String> The name or address of the location (default to "MyLocation" unless specified)
                    preferences: [String]  (default is empty)
                    }, {...}] }
                """,
                model: gptModel!,
                responseFormat: jsonResponseFormat)
            
            print(response)
            
            return response
        } catch {
            return "Send OpenAI Query Error: \(error.localizedDescription)"
        }
    }
    
    //interacts GPT and returns a JSON representing the information that the user provided in their query
    func queryChatGPT(query: String) async -> String? {
        do {
            let response = try await openAIAPIKey.sendMessage(
                text: """
                    I will give you a question or statement. From this, extract the following information and format it as JSON. The price field should default to "1,2,3,4" and be adjusted to include upper or lower ranges based on the user's price preference. Location is default "MyLocation", unless user mentions a different location. If the user does not mention a time, set the time field to -1. Same with distance. For locationInformation, default is a blank string, unless there is more specific info about the location type (e.g., "Museum" if the locationType is "Activity"). Include a one-line response to the user's query asking for more information or incorporating their feedback, such as "Here's what I found."
                    {
                    locationType: <Restaurant/Gas Station/Hotel/Rest Stop/Activity/Shopping>
                    locationInformation: <String>
                    distance: <Double>
                    time: <Double (in seconds)>
                    price: <String> (Default is "1,2,3,4")
                    location: <String>
                    preferences: [String]
                    atlasResponse: <String>
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
        currentLocationType = locationType
        let locationInformation = locationInfo.locationInformation
        let distance = locationInfo.distance
        let location = locationInfo.location
        var time = locationInfo.time
        let price = locationInfo.price
        let preferences = locationInfo.preferences.joined(separator: ", ")
        atlasResponse = locationInfo.atlasResponse ?? "Here's what I found"
        
        if(location == "MyLocation") {
            var coords: CLLocationCoordinate2D
            if(time == -1.0) {
                if(distance != -1.0) {
                    time = 0
                    coords = await getCoordsFromTime(time: time, userVM: userVM)
                    print("trytyrtry")
                } else {
                    coords = await getCoordsFromDistance(distance: distance, userVM: userVM)
                    print("lmlmlml")
                }
            } else {
                coords = await getCoordsFromTime(time: time, userVM: userVM)
                print("weee")
            }
            
            print("ai coords \(coords)")
            
            
            
            guard let businessInformation = await fetchSpecificBusinesses(locationType: (locationInformation == "") ? locationType : locationInformation, distance: 2, price: price, location: "UseCoords", preferences: preferences, latitude: coords.latitude, longitutde: coords.longitude, limit: 3) else {
                return "Error: Unable to access YELP API"
            }
            return businessInformation
            
            
        } else {
            guard let businessInformation = await fetchSpecificBusinesses(locationType: (locationInformation == "") ? locationType : locationInformation, distance: distance, price: price, location: location, preferences: preferences, latitude: 0.0, longitutde: 0.0, limit: 3) else {
                return "Error: Unable to access YELP API"
            }
            return businessInformation
        }
    }
    
    func getCoordsFromTime(time: Double, userVM: UserViewModel) async -> CLLocationCoordinate2D{
        let sampleRoute = await MapManager.manager.getExampleRoute()!
        let route = userVM.current_trip?.route
        
        let coords = MapManager.manager.getFutureLocation(time: time, route: route ?? sampleRoute) ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        return coords
    }
    
    func getCoordsFromDistance(distance: Double, userVM: UserViewModel) async -> CLLocationCoordinate2D{
        let sampleRoute = await MapManager.manager.getExampleRoute()!
        let route = userVM.current_trip?.route
        
        
        let coords = MapManager.manager.getFutureLocationByDistance(distance: distance, route: route ?? sampleRoute) ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        
        return coords
    }
    
    //This function calls Yelp with the specified parameters and returns the Yelp APIs JSON
    func fetchSpecificBusinesses(locationType: String, distance: Double, price: String, location: String, preferences: String, latitude: Double, longitutde: Double, limit: Int) async -> String? {
        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "term", value: "\(preferences)  \(locationType)"),
            URLQueryItem(name: "price", value: price),
            URLQueryItem(name: "radius", value: "\(2 * 1609)"), //Because the parameter takes in meters, we convert miles to meters (1 mile = 1608.34 meters)
            URLQueryItem(name: "limit", value: String(limit)),
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
            return LocationInfo(locationType: "", locationInformation: "", distance: -1, time: 0.0, price: "1,2,3,4", location: "", preferences: [], atlasResponse: "Need more information")
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
