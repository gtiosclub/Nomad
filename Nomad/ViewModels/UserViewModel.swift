//
//  UserViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import MapKit

class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var current_trip: Trip?
    @Published var restaurants: [Restaurant] = []
    @Published var hotels: [Hotel] = []
    @Published var activities: [Activity] = []
    @Published var generalLocations: [GeneralLocation] = []
    
    init(user: User? = nil) {
        self.user = user
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    func createNewUser(name: String) {
        self.user = User(id: UUID().uuidString, name: name)
    }
    
    func createTrip(start: POI, end: POI) -> Trip {
        self.current_trip = Trip(start_location: start, end_location: end)
        return current_trip!
    }
    
    func addTripToUser(trip: Trip) {
        if let user = user {
            user.addTrip(trip: trip)
            objectWillChange.send()
        }
    }
    
    func getTrips() -> [Trip] {
        return user?.getTrips() ?? []
    }
    
    func addStop(stop: POI) {
        current_trip?.addStops(additionalStops: [stop])
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func removeStop(stop: POI) {
        current_trip?.removeStops(removedStops: [stop])
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setCurrentTrip(trip: Trip) {
        self.current_trip = trip
    }
    
    func setStartLocation(new_start_location: POI) {
        current_trip?.setStartLocation(new_start_location: new_start_location)
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setEndLocation(new_end_location: POI) {
        current_trip?.setEndLocation(new_end_location: new_end_location)
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setTripStartDate(startDate: String) {
        current_trip?.setStartDate(newDate: startDate)
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setTripEndDate(endDate: String) {
        current_trip?.setEndDate(newDate: endDate)
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setCurrentTrip(by tripID: String) {
        guard let user = user else { return }
        
        if let trip = user.findTrip(id: tripID) {
            current_trip = trip
        }
    }

    func fetchPlaces(location: String, stopType: String, rating: Double?, price: Int?, cuisine: String?) async {
        let apiKey = ""
        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!
        guard let currentTrip = current_trip else { return }
        let startLocation = currentTrip.getStartLocation()

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "location", value: startLocation.getAddress()),
            URLQueryItem(name: "term", value: stopType),
            URLQueryItem(name: "sort_by", value: "best_match"),
        ]

        if let price = price, price > 0 {
            queryItems.append(URLQueryItem(name: "price", value: String(price)))
        }

        if let rating = rating {
            queryItems.append(URLQueryItem(name: "rating", value: String(rating)))
        }

        if let cuisine = cuisine, cuisine != "All" && !cuisine.isEmpty {
            queryItems.append(URLQueryItem(name: "categories", value: cuisine))
        }

        components.queryItems = queryItems
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            let response = try decoder.decode(YelpResponse.self, from: data)

            DispatchQueue.main.async {
                switch stopType {
                case "Restaurants":
                    self.restaurants = response.businesses.map { Restaurant(from: $0) }
                case "Hotels":
                    self.hotels = response.businesses.map { Hotel(from: $0) }
                case "Activities":
                    self.activities = response.businesses.map { Activity(from: $0) }
                default:
                    for business in response.businesses {
                        let generalLocation = GeneralLocation(address: business.location.address1 ?? "No address", name: business.name)
                        self.generalLocations.append(generalLocation)
                    }
                }
            }
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    func getCategoryForStopType(stopType: String) -> String {
        switch stopType {
        case "Food":
            return "restaurants"
        case "Activities":
            return "activities"
        case "Scenic":
            return "scenic"
        case "Hotels":
            return "hotels"
        case "Tours and Landmarks":
            return "tours,landmarks"
        case "Entertainment":
            return "entertainment"
        default:
            return "restaurants"
        }
    }
}

struct YelpResponse: Codable {
    let businesses: [Business]
}

struct Business: Codable {
    let id: String
    let name: String
    let location: Location
    let rating: Double?
    let categories: [Category]
    let price: String?
    let url: String?
}

struct Location: Codable {
    let address1: String?
}

struct Category: Codable {
    let title: String
}
