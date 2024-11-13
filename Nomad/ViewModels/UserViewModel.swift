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
    @Published var total_distance: Double = 0
    @Published var total_time: Double = 0
    @Published var restaurants: [Restaurant] = []
    @Published var hotels: [Hotel] = []
    @Published var activities: [Activity] = []
    @Published var shopping: [Shopping] = []
    @Published var generalLocations: [GeneralLocation] = []
    @Published var reststops: [RestStop] = []
    @Published var distances: [Double] = []
    @Published var times: [Double] = []
    @Published var currentCity: String?
    @Published var currentAddress: String?
    
    @Published var previous_trips: [Trip] = []
    @Published var community_trips: [Trip] = []
    
    var aiVM = AIAssistantViewModel()
    var fbVM = FirebaseViewModel.vm
    
    init(user: User) {
        self.user = user
    }
    
    func populateUserTrips() async {
        print(user.id)
        let allTrips = await fbVM.getAllTrips(userID: user.id)
        DispatchQueue.main.async {
            self.user.trips = allTrips["future"]!
            self.previous_trips = allTrips["past"]!
        }
//        self.previous_trips = user.pastTrips
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
    func createTrip(start_location: any POI, end_location: any POI, start_date: String = "", end_date: String = "", stops: [any POI] = [], start_time: String = "8:00 AM") async {
        let temp_trip = Trip(start_location: start_location, end_location: end_location, start_date: start_date, end_date: end_date, stops: stops, start_time: start_time)

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
            let from_start = await getDistanceCoordinates(from: start_coordinates, to: stop_coordinates)
            var from_stops: [Double] = []
            for current_stop in trip.getStops() {
                let current_stop_coordinates = CLLocationCoordinate2D(latitude: current_stop.getLatitude(), longitude: current_stop.getLongitude())
                from_stops.append(await getDistanceCoordinates(from: current_stop_coordinates, to: stop_coordinates))
            }
            let min_stop_distance = from_stops.min() ?? 10000000
            
            let index: Int
            if min_stop_distance < from_start {
                index = from_stops.firstIndex(of: min_stop_distance)!
            } else {
                index = 0
            }
            if await fbVM.addStopToTrip(tripID: current_trip!.id, stop:stop, index: index) {
                current_trip?.addStopAtIndex(newStop: stop, index: (index > 0 ? index + 1: 0))
                user.updateTrip(trip: current_trip!)
                self.user = user
            } else {
                print("Failed to add stop")
            }
            
        }
    }
    
    func removeStop(stop: any POI) async {
        if await fbVM.removeStopFromTrip(tripID: current_trip!.id, stop: stop) {
            current_trip?.removeStops(removedStops: [stop])
            user.updateTrip(trip: current_trip!)
            self.user = user
        }
    }
    
    func setCurrentTrip(trip: Trip) {
        self.current_trip = trip
        Task{
            await getTotalDistance()
            await getTotalTime()
        }
    }
    
    func setStartLocation(new_start_location: any POI) {
        current_trip?.setStartLocation(new_start_location: new_start_location)
        user.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setEndLocation(new_end_location: any POI) {
        current_trip?.setEndLocation(new_end_location: new_end_location)
        user.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setStartDate(startDate: String) {
        current_trip?.setStartDate(newDate: startDate)
        user.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setEndDate(endDate: String) {
        current_trip?.setEndDate(newDate: endDate)
        user.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setStartTime(startTime: String) {
        current_trip?.setStartTime(newTime: startTime)
        user.updateTrip(trip: current_trip!)
        self.user = user
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

    func setCurrentTrip(by tripID: String) {
        if let trip = user.findTrip(id: tripID) {
            current_trip = trip
        }
        
        Task{
            await getTotalDistance()
            await getTotalTime()
        }
    }
    
    func getTotalDistance() async {
        guard let current_trip else { return }
        
        var totalDist = 0.0
        let stops = current_trip.getStops()
        if stops.count == 0 {
            totalDist = await getDistance(fromAddress: current_trip.getStartLocation().address, toAddress: current_trip.getEndLocation().address)
        } else {
            totalDist += await getDistance(fromAddress: current_trip.getStartLocation().address, toAddress: stops[0].address)
            for i in 1..<stops.count {
                totalDist += await getDistance(fromAddress: stops[i-1].address, toAddress: stops[i].address)
            }
            totalDist += await getDistance(fromAddress: stops[stops.count-1].address, toAddress: current_trip.getEndLocation().address)
        }
        DispatchQueue.main.async {
            self.total_distance = totalDist * 0.000621371
        }
    }
    
    func getTotalTime() async {
        guard let current_trip else { return }
        
        var totalTime = 0.0
        let stops = current_trip.getStops()
        if stops.count == 0 {
            totalTime = await getTime(fromAddress: current_trip.getStartLocation().address, toAddress: current_trip.getEndLocation().address)
        } else {
            totalTime += await getTime(fromAddress: current_trip.getStartLocation().address, toAddress: stops[0].address)
            for i in 1..<stops.count {
                totalTime += await getTime(fromAddress: stops[i-1].address, toAddress: stops[i].address)
            }
            totalTime += await getTime(fromAddress: stops[stops.count-1].address, toAddress: current_trip.getEndLocation().address)
        }
        DispatchQueue.main.async {
            self.total_time = totalTime / 60
        }
    }

    func getDistance(fromAddress: String, toAddress: String) async -> (Double) {
        let geoCoder = CLGeocoder()
        var fromLocation: CLLocation?
        var toLocation: CLLocation?
        
        do {
            if let fromPlacemark = try await geoCoder.geocodeAddressString(fromAddress).first,
               let toPlacemark = try await geoCoder.geocodeAddressString(toAddress).first {
                fromLocation = fromPlacemark.location
                toLocation = toPlacemark.location
            }
        } catch {
            print("Error during geocoding: \(error)")
            return 0.0
        }
        
        guard let fromLocation, let toLocation else { return 0.0 }
        
        let fromPlacemark = MKPlacemark(coordinate: fromLocation.coordinate)
        let toPlacemark = MKPlacemark(coordinate: toLocation.coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: fromPlacemark)
        request.destination = MKMapItem(placemark: toPlacemark)
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
    
    func getTime(fromAddress: String, toAddress: String) async -> (Double) {
        let geoCoder = CLGeocoder()
        var fromLocation: CLLocation?
        var toLocation: CLLocation?
        
        do {
            if let fromPlacemark = try await geoCoder.geocodeAddressString(fromAddress).first,
               let toPlacemark = try await geoCoder.geocodeAddressString(toAddress).first {
                fromLocation = fromPlacemark.location
                toLocation = toPlacemark.location
            }
        } catch {
            print("Error during geocoding: \(error)")
            return 0.0
        }
        
        guard let fromLocation, let toLocation else { return 0.0 }
        
        let fromPlacemark = MKPlacemark(coordinate: fromLocation.coordinate)
        let toPlacemark = MKPlacemark(coordinate: toLocation.coordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: fromPlacemark)
        request.destination = MKMapItem(placemark: toPlacemark)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        do {
            let response = try await directions.calculate()
            return response.routes.first?.expectedTravelTime ?? 0.0
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
        self.distances.removeAll()
        self.times.removeAll()
        for leg in current_trip?.route?.legs ?? [] {
            self.times.append(leg.totalTime() / 60)
            self.distances.append(leg.totalDistance())
        }
    }
    
    func calculateLegInfo() async {
        DispatchQueue.main.async {
            
        }
        
        guard let currentTrip = current_trip else { return }
        let stops = currentTrip.getStops()
        
        let startLocation = currentTrip.getStartLocation()
        let startAddress = startLocation.address
        let endLocation = currentTrip.getEndLocation()
        let endAddress = endLocation.address
        
        if !stops.isEmpty {
            let firstStopAddress = stops[0].address
            
            let estimatedTimeToFirstStop = await getTime(fromAddress: startAddress, toAddress: firstStopAddress)
            DispatchQueue.main.async {
                self.times.append(estimatedTimeToFirstStop / 60)
            }
            let estimatedDistanceToFirstStop = await getDistance(fromAddress: startAddress, toAddress: firstStopAddress)
            DispatchQueue.main.async {
                self.distances.append(estimatedDistanceToFirstStop * 0.000621371)
            }
        } else {
            let estimatedTimeToEnd = await getTime(fromAddress: startAddress, toAddress: endAddress)
            DispatchQueue.main.async {
                self.times.append(estimatedTimeToEnd / 60)
            }
            let estimatedDistanceToEnd = await getDistance(fromAddress: startAddress, toAddress: endAddress)
            DispatchQueue.main.async {
                self.distances.append(estimatedDistanceToEnd * 0.000621371)
            }
        }
        
        if stops.count != 0 {
            for i in 0..<stops.count - 1 {
                let startLocationAddress = stops[i].address
                let endLocationAddress = stops[i + 1].address
                
                let estimatedTime = await getTime(fromAddress: startLocationAddress, toAddress: endLocationAddress)
                DispatchQueue.main.async {
                    self.times.append(estimatedTime / 60)
                }
                
                let distance = await getDistance(fromAddress: startLocationAddress, toAddress: endLocationAddress)
                DispatchQueue.main.async {
                    self.distances.append(distance * 0.000621371)
                }
            }
        }
        
        if let lastStop = stops.last {
            let lastStopAddress = lastStop.address
            let estimatedTimeToEnd = await getTime(fromAddress: lastStopAddress, toAddress: endAddress)
            DispatchQueue.main.async {
                self.times.append(estimatedTimeToEnd / 60)
            }
            
            let estimatedDistanceToEnd = await getDistance(fromAddress: lastStopAddress, toAddress: endAddress)
            DispatchQueue.main.async {
                self.distances.append(estimatedDistanceToEnd * 0.000621371)
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
        total_time = 0
        total_distance = 0
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
