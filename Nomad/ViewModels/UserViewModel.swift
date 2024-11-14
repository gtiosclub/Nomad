//
//  UserViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import MapKit
import CoreLocation
import Combine

class UserViewModel: ObservableObject {
    @Published var user: User
    @Published var current_trip: Trip?
    
    @Published var previous_trips: [Trip] = []
    @Published var community_trips: [Trip] = []
    
    @Published var distances: [Double] = []
    @Published var times: [Double] = []
    @Published var currentCity: String?
    @Published var currentAddress: String?
    
    @Published var restaurants: [Restaurant] = []
    @Published var hotels: [Hotel] = []
    @Published var activities: [Activity] = []
    @Published var shopping: [Shopping] = []
    @Published var generalLocations: [GeneralLocation] = []
    @Published var reststops: [RestStop] = []
    
    var aiVM = AIAssistantViewModel()
    var fbVM = FirebaseViewModel.vm
    
    init(user: User) {
        self.user = user
    }
    
    func populateUserTrips() async {
        let allTrips = await fbVM.getAllTrips(userID: user.id)
        DispatchQueue.main.async {
            self.user.trips = allTrips["future"]!
            self.previous_trips = allTrips["past"]!
            self.user.pastTrips = allTrips["past"]!
        }

        let communityTrips = await fbVM.getAllPublicTrips(userID: user.id)
        DispatchQueue.main.async {
            self.community_trips = communityTrips
        }
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    func createNewUser(name: String) {
        self.user = User(id: UUID().uuidString, name: name)
    }
    
    @MainActor
    func createTrip(start_location: any POI, end_location: any POI, start_date: String = "", end_date: String = "", stops: [any POI] = [], start_time: String = "8:00 AM", coverImageURL: String = "") async {
        let temp_trip = Trip(start_location: start_location, end_location: end_location, start_date: start_date, end_date: end_date, stops: stops, start_time: start_time, coverImageURL: coverImageURL)

        if await fbVM.createTrip(tripID: temp_trip.id, createdDate: Trip.getCurrentDateTime(), modifiedDate: temp_trip.modified_date, startDate: start_date, startTime: start_time, endDate: end_date, isPrivate: false, startLocation: start_location, endLocation: end_location) {
            if await fbVM.addTripToUser(userID: user.id, tripID: temp_trip.id) {
                self.current_trip = temp_trip
                let route = await getRoute()
                self.current_trip?.route = route
                
                self.user.addTrip(trip: self.current_trip!)
            }
        }
    }
    
    func addTripToUser(trip: Trip) {
        user.addTrip(trip: trip)
        objectWillChange.send()
    }
    
    func getTrips() -> [Trip] {
        return user.getTrips()
    }
    
    func addStop(stop: any POI) async {
        if let trip = current_trip {
            let start_coordinates = CLLocationCoordinate2D(latitude: trip.getStartLocation().getLatitude(), longitude: trip.getStartLocation().getLongitude())
            let stop_coordinates = CLLocationCoordinate2D(latitude: stop.getLatitude(), longitude: stop.getLongitude())
            
            // Calculate distance from the start to the new stop
            let from_start_to_new_stop = await getDistanceCoordinates(from: start_coordinates, to: stop_coordinates)
            
            var index = 0 // Default to inserting right after the start location
            if !trip.getStops().isEmpty {
                // Compute cumulative distances from start to each stop
                var cumulative_distances: [Double] = []
                var previous_stop_coordinates = start_coordinates
                var cumulative_distance = 0.0
                
                for existing_stop in trip.getStops() {
                    let current_stop_coordinates = CLLocationCoordinate2D(latitude: existing_stop.getLatitude(), longitude: existing_stop.getLongitude())
                    cumulative_distance += await getDistanceCoordinates(from: previous_stop_coordinates, to: current_stop_coordinates)
                    cumulative_distances.append(cumulative_distance)
                    previous_stop_coordinates = current_stop_coordinates
                }
                
                // Calculate total distance to the end location to insert after the last stop if necessary
                let end_coordinates = CLLocationCoordinate2D(latitude: trip.getEndLocation().getLatitude(), longitude: trip.getEndLocation().getLongitude())
                let last_stop_to_end = await getDistanceCoordinates(from: previous_stop_coordinates, to: end_coordinates)
                let total_distance = cumulative_distance + last_stop_to_end
                
                // Find insertion index by comparing cumulative distances
                index = cumulative_distances.count
                if from_start_to_new_stop < cumulative_distances.first! {
                    // Insert after start, before first stop
                    index = 0
                } else if from_start_to_new_stop <= total_distance {
                    // Find the correct place between stops
                    for (i, distance) in cumulative_distances.enumerated() {
                        if from_start_to_new_stop < distance {
                            index = i // Insert at this position
                            break
                        }
                    }
                }
            }
            
            current_trip?.addStopAtIndex(newStop: stop, index: index)
            user.updateTrip(trip: current_trip!)
            DispatchQueue.main.async {
                self.user = self.user
            }
        }
    }
    
    func removeStop(stopId: String) {
        current_trip?.removeStop(stopId: stopId)
    }
    
    func setCurrentTrip(trip: Trip) {
        self.current_trip = trip
    }
    
    func setStartLocation(new_start_location: any POI) {
        current_trip?.setStartLocation(new_start_location: new_start_location)
    }
    
    func setEndLocation(new_end_location: any POI) {
        current_trip?.setEndLocation(new_end_location: new_end_location)
    }
    
    func setStartDate(startDate: String) {
        current_trip?.setStartDate(newDate: startDate)
    }
    
    func setEndDate(endDate: String) {
        current_trip?.setEndDate(newDate: endDate)
    }
    
    func setStartTime(startTime: String) {
        current_trip?.setStartTime(newTime: startTime)
    }
    
    func updateRoute() async {
        if let trip = current_trip {
            var pois = [trip.getStartLocation()]
            pois.append(contentsOf: trip.getStops())
            pois.append(trip.getEndLocation())
            if let routes = await MapManager.manager.generateRoute(pois: pois) {
                DispatchQueue.main.async {
                    trip.setRoute(route: routes[0]) // set main route
                }
            }
        }
    }
    
    func getRoute() async -> NomadRoute? {
        if let trip = current_trip {
            var pois = [trip.getStartLocation()]
            pois.append(contentsOf: trip.getStops())
            pois.append(trip.getEndLocation())
            if let routes = await MapManager.manager.generateRoute(pois: pois) {
                print("found route: \(routes[0])")
                return routes[0]
            }
        }
        return nil
    }
    
    func setTripRoute(route: NomadRoute) {
        current_trip?.setRoute(route: route)
        user.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func getDistanceCoordinates(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) async -> (Double) {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            return response.routes.first?.distance ?? 0.0
        } catch {
            print("Error: \(error)")
        }
        
        return 0.0
    }
    
    @Published var navigatingTrip: Trip? = nil
    func startTrip(trip: Trip) {
        self.navigatingTrip = trip
    }
    
    func populateLegInfo() {
        DispatchQueue.main.async {
            self.distances.removeAll()
            self.times.removeAll()
            for leg in self.current_trip?.route?.legs ?? [] {
                self.times.append(leg.totalTime() / 60)
                self.distances.append(leg.totalDistance())
            }
        }
    }

    func fetchPlaces(latitude: String, longitude: String, stopType: String, rating: Double?, price: Int?, cuisine: String?, searchString: String) async {
        let apiKey = aiVM.yelpAPIKey
        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!
        guard let currentTrip = current_trip else { return }
        //let startLocation = currentTrip.getStartLocation()

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        var queryItems: [URLQueryItem] = []
        
        print(searchString)
        
        if (searchString != "") {
            print("Searching via search bar")
            queryItems = [
                URLQueryItem(name: "latitude", value: latitude),
                URLQueryItem(name: "longitude", value: longitude),
                URLQueryItem(name: "term", value: searchString),
                URLQueryItem(name: "sort_by", value: "rating"),
                URLQueryItem(name: "limit", value: "50")
            ]
        } else if (stopType == "Restaurants") {
            queryItems = [
                URLQueryItem(name: "latitude", value: latitude),
                URLQueryItem(name: "longitude", value: longitude),
                URLQueryItem(name: "categories", value: "restaurants,food"),
                URLQueryItem(name: "sort_by", value: "rating"),
                URLQueryItem(name: "limit", value: "50")
            ]
            if let cuisine = cuisine, cuisine != "All" && !cuisine.isEmpty {
                queryItems.append(URLQueryItem(name: "categories", value: cuisine))
            }
            if let price = price, price > 0 {
                queryItems.append(URLQueryItem(name: "price", value: String(price)))
            }
        } else if (stopType == "Activities") {
            queryItems = [
                URLQueryItem(name: "latitude", value: latitude),
                URLQueryItem(name: "longitude", value: longitude),
                URLQueryItem(name: "categories", value: "activelife,nightlife,facepainting,photoboothrentals,photographers,silentdisco,videographers,triviahosts,teambuilding,massage,hotspring"),
                URLQueryItem(name: "sort_by", value: "rating"),
                URLQueryItem(name: "limit", value: "50")
            ]
        } else if (stopType == "Scenic") {
            queryItems = [
                URLQueryItem(name: "latitude", value: latitude),
                URLQueryItem(name: "longitude", value: longitude),
                URLQueryItem(name: "term", value: "sights"),
                URLQueryItem(name: "sort_by", value: "rating"),
                URLQueryItem(name: "limit", value: "50")
            ]
        } else if (stopType == "Hotels") {
            queryItems = [
                URLQueryItem(name: "latitude", value: latitude),
                URLQueryItem(name: "longitude", value: longitude),
                URLQueryItem(name: "categories", value: "hotels,hostels"),
                URLQueryItem(name: "sort_by", value: "rating"),
                URLQueryItem(name: "limit", value: "50")
            ]
        } else if (stopType == "Tours and Landmarks") {
            queryItems = [
                URLQueryItem(name: "latitude", value: latitude),
                URLQueryItem(name: "longitude", value: longitude),
                URLQueryItem(name: "categories", value: "tours,landmarks,collegeuniv,hotsprings"),
                URLQueryItem(name: "sort_by", value: "rating"),
                URLQueryItem(name: "limit", value: "50")
            ]
        } else if (stopType == "Shopping") {
            queryItems = [
                URLQueryItem(name: "latitude", value: latitude),
                URLQueryItem(name: "longitude", value: longitude),
                URLQueryItem(name: "term", value: "shopping"),
                URLQueryItem(name: "sort_by", value: "rating"),
                URLQueryItem(name: "limit", value: "50")
            ]
        } else { //entertainment
            queryItems = [
                URLQueryItem(name: "latitude", value: latitude),
                URLQueryItem(name: "longitude", value: longitude),
                URLQueryItem(name: "categories", value: "arts,magicians,musicians"),
                URLQueryItem(name: "sort_by", value: "rating"),
                URLQueryItem(name: "limit", value: "50")
            ]
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
            
            let filteredBusinesses = response.businesses.filter { business in
                guard let businessRating = business.rating else { return false }
                let meetsRatingCriteria = rating == nil || businessRating >= rating!
                let hasValidAddress = business.location.display_address.count >= 2
                return meetsRatingCriteria && hasValidAddress
            }

            DispatchQueue.main.async {
                switch stopType {
                case "Restaurants":
                    self.restaurants = filteredBusinesses.map { Restaurant(from: $0) }
                case "Hotels":
                    self.hotels = filteredBusinesses.map { Hotel(from: $0) }
                case "Activities":
                    self.activities = filteredBusinesses.map { Activity(from: $0) }
                case "Shopping":
                    self.shopping = filteredBusinesses.map { Shopping(from: $0) }
                default:
                    self.generalLocations = filteredBusinesses.map { GeneralLocation(from: $0) }
                }
            }
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Missing key: '\(key.stringValue)' in JSON data: \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type mismatch for the \(type) with description: \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type , let context) {
            print("Value not ofund for the type \(type), \(context.debugDescription)")
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    func fetchRestStops(latitude: String, longitude: String) async {
        let apiKey = aiVM.yelpAPIKey
        let url = URL(string: "https://api.yelp.com/v3/businesses/search")!

        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        
        let queryItems: [URLQueryItem] = [
          URLQueryItem(name: "categories", value: "reststops"),
          URLQueryItem(name: "latitude", value: latitude),
          URLQueryItem(name: "longitude", value: longitude),
          URLQueryItem(name: "sort_by", value: "rating"),
          URLQueryItem(name: "limit", value: "50"),
        ]

        components.queryItems = queryItems
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let decoder = JSONDecoder()
            
            let response = try decoder.decode(YelpResponse.self, from: data)
            
            self.reststops = response.businesses.compactMap { business -> RestStop? in
                guard business.location.display_address.count >= 2 else { return nil }
                return RestStop(from: business)
            }
            
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
        } catch DecodingError.keyNotFound(let key, let context) {
            print("Missing key: '\(key.stringValue)' in JSON data: \(context.debugDescription)")
        } catch DecodingError.typeMismatch(let type, let context) {
            print("Type mismatch for the \(type) with description: \(context.debugDescription)")
        } catch DecodingError.valueNotFound(let type , let context) {
            print("Value not ofund for the type \(type), \(context.debugDescription)")
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    
    func getCurrentCity() async {
        let locationManager = CLLocationManager()
        guard let userLocation = locationManager.location else {
            return
        }
        
        let geoCoder = CLGeocoder()
        do {
            if let placemark = try await geoCoder.reverseGeocodeLocation(userLocation).first {
                DispatchQueue.main.async {
                    self.currentCity = placemark.locality!
                    let pa = placemark.postalAddress
                    self.currentAddress = "\(pa?.street ?? ""), \(pa?.city ?? ""), \(pa?.state ?? "") \(pa?.postalCode ?? "")"
                }
            }
        } catch {
            print("Error during reverse geocoding: \(error)")
        }
        
        return
    }
    
    func getCoordinates(for address: String) async -> (latitude: Double, longitude: Double)? {
        let geoCoder = CLGeocoder()
        
        do {
            if let placemark = try await geoCoder.geocodeAddressString(address).first,
               let location = placemark.location {
                return (location.coordinate.latitude, location.coordinate.longitude)
            }
        } catch {
            print("Error during geocoding: \(error)")
        }
        
        return nil
    }
    
    func setTripTitle(newTitle: String) {
        current_trip?.setName(newName: newTitle)
        user.updateTrip(trip: current_trip!)
        self.user = user
    }

    func getTripTitle() -> String {
        return current_trip?.getName() ?? "Unnamed Trip"
    }

    func setIsPrivate(isPrivate: Bool) {
        current_trip?.setVisibility(isPrivate: isPrivate)
        user.updateTrip(trip: current_trip!)
        self.user = user
    }

    func getTripVisibility() -> Bool {
        return current_trip?.setIsPrivate() ?? true
    }
    
    func reorderStops(fromOffsets: IndexSet, toOffset: Int) {
        current_trip?.reorderStops(fromOffsets: fromOffsets, toOffset: toOffset)
    }

    func clearCurrentTrip() {
        current_trip = nil
        times = []
        distances = []
    }
    
    func getUser() -> User {
        user
    }
}


struct YelpResponse: Codable {
    let businesses: [Business]
}

struct Business: Codable {
    let id: String
    let name: String
    let coordinates: Coordinates
    let location: Location
    let rating: Double?
    let categories: [Category]?
    let price: String?
    let url: String?
    let image_url: String?
}

struct Location: Codable {
    let city: String
    let display_address: [String]
}

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct Category: Codable {
    let alias: String
    let title: String
}

struct RouteLeg {
    let distance: Double
    let time: Double
}
