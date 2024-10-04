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
    @Published var user: User?
    @Published var current_trip: Trip?
    @Published var total_distance: Double = 0
    @Published var total_time: Double = 0
    @Published var restaurants: [Restaurant] = []
    @Published var hotels: [Hotel] = []
    @Published var activities: [Activity] = []
    @Published var generalLocations: [GeneralLocation] = []
    @Published var distances: [Double] = []
    @Published var times: [Double] = []
    
    init(user: User? = nil) {
        self.user = user
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    func createNewUser(name: String) {
        self.user = User(id: UUID().uuidString, name: name)
    }
    
    func createTrip(start: any POI, end: any POI) -> Trip {
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
    
    func addStop(stop: any POI) {
        current_trip?.addStops(additionalStops: [stop])
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func removeStop(stop: any POI) {
        current_trip?.removeStops(removedStops: [stop])
        user?.updateTrip(trip: current_trip!)
        self.user = user
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
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setEndLocation(new_end_location: any POI) {
        current_trip?.setEndLocation(new_end_location: new_end_location)
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setStartDate(startDate: String) {
        current_trip?.setStartDate(newDate: startDate)
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setEndDate(endDate: String) {
        current_trip?.setEndDate(newDate: endDate)
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    
    func setStartTime(startTime: String) {
        current_trip?.setStartTime(newTime: startTime)
        user?.updateTrip(trip: current_trip!)
        self.user = user
    }
    func setCurrentTrip(by tripID: String) {
        guard let user = user else { return }
        
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
            self.total_distance = totalDist
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
            self.total_time = totalTime
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
    
    func calculateLegInfo() async {
        distances.removeAll()
        times.removeAll()
        
        guard let currentTrip = current_trip else { return }
        let stops = currentTrip.getStops()

        let startLocation = currentTrip.getStartLocation()
        let startAddress = startLocation.address
        let endLocation = currentTrip.getEndLocation()
        let endAddress = endLocation.address

        if !stops.isEmpty {
            let firstStopAddress = stops[0].address
            
            let estimatedTimeToFirstStop = await getTime(fromAddress: startAddress, toAddress: firstStopAddress)
            times.append(estimatedTimeToFirstStop / 60)

            let estimatedDistanceToFirstStop = await getDistance(fromAddress: startAddress, toAddress: firstStopAddress)
            distances.append(estimatedDistanceToFirstStop * 0.000621371)
        } else {
            let estimatedTimeToEnd = await getTime(fromAddress: startAddress, toAddress: endAddress)
            times.append(estimatedTimeToEnd / 60)

            let estimatedDistanceToEnd = await getDistance(fromAddress: startAddress, toAddress: endAddress)
            distances.append(estimatedDistanceToEnd * 0.000621371)
        }

        for i in 0..<stops.count - 1 {
            let startLocationAddress = stops[i].address
            let endLocationAddress = stops[i + 1].address
            
            let estimatedTime = await getTime(fromAddress: startLocationAddress, toAddress: endLocationAddress)
            times.append(estimatedTime / 60)
            
            let distance = await getDistance(fromAddress: startLocationAddress, toAddress: endLocationAddress)
            distances.append(distance * 0.000621371)
        }

        if let lastStop = stops.last {
            let lastStopAddress = lastStop.address
            let estimatedTimeToEnd = await getTime(fromAddress: lastStopAddress, toAddress: endAddress)
            times.append(estimatedTimeToEnd / 60)

            let estimatedDistanceToEnd = await getDistance(fromAddress: lastStopAddress, toAddress: endAddress)
            distances.append(estimatedDistanceToEnd * 0.000621371)
        }
    }


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

struct RouteLeg {
    let distance: Double
    let time: Double
}
