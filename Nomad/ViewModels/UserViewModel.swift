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
    @Published var mapManager = MapManager()
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
    @Published var currentCity: String?
    
    @Published var my_trips: [Trip] = []
    @Published var previous_trips: [Trip] = []
    @Published var community_trips: [Trip] = []

    
    init(user: User? = nil) {
        self.user = user
        if user?.getTrips().count ?? 0 >= 1 {
            if let trip = user?.getTrips()[0] {
                current_trip = trip
            }
        }
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    func createNewUser(name: String) {
        self.user = User(id: UUID().uuidString, name: name)
    }
    
    func createTrip(start_location: any POI, end_location: any POI, start_date: String = "", end_date: String = "", stops: [any POI] = [], start_time: String = "8:00 AM") async -> Trip {
        self.current_trip = Trip(start_location: start_location, end_location: end_location, start_date: start_date, end_date: end_date, stops: stops, start_time: start_time)
        await updateRoute()
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
    
    func addStop(stop: any POI) async {
        if let trip = current_trip {
            print(trip.getStartLocation().getAddress())
            print(stop.getAddress())
            let start_coordinates = CLLocationCoordinate2D(latitude: trip.getStartLocation().getLatitude()!, longitude: trip.getStartLocation().getLongitude()!)
            let stop_coordinates = CLLocationCoordinate2D(latitude: stop.getLatitude()!, longitude: stop.getLongitude()!)
            let from_start = await getDistanceCoordinates(from: start_coordinates, to: stop_coordinates)
            var from_stops: [Double] = []
            for current_stop in trip.getStops() {
                print(current_stop.getAddress())
                let current_stop_coordinates = CLLocationCoordinate2D(latitude: current_stop.getLatitude()!, longitude: current_stop.getLongitude()!)
                from_stops.append(await getDistanceCoordinates(from: current_stop_coordinates, to: stop_coordinates))
            }
            print(from_start)
            print(from_stops)
            let min_stop_distance = from_stops.min() ?? 10000000
            if min_stop_distance < from_start {
                let index = from_stops.firstIndex(of: min_stop_distance)!
                current_trip?.addStopAtIndex(newStop: stop, index: index + 1)
                user?.updateTrip(trip: current_trip!)
                self.user = user
            } else {
                current_trip?.addStopAtIndex(newStop: stop, index: 0)
                user?.updateTrip(trip: current_trip!)
                self.user = user
            }
        }
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
    
    func updateRoute() async {
        if let trip = current_trip {
            var pois = [trip.getStartLocation()]
            pois.append(contentsOf: trip.getStops())
            pois.append(trip.getEndLocation())
            if let routes = await mapManager.generateRoute(pois: pois) {
                self.current_trip?.setRoute(route: routes[0]) // set main route
            }
        }
    }
    
    func setTripRoute(route: NomadRoute) {
        current_trip?.setRoute(route: route)
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
            self.total_distance = totalDist / 1609
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
            self.total_time = totalTime / 3600
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
    
    func calculateLegInfo() async {
            DispatchQueue.main.async {
                self.distances.removeAll()
                self.times.removeAll()
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


    func fetchPlaces(location: String, stopType: String, rating: Double?, price: Int?, cuisine: String?) async {
        let apiKey = "hpQdyXearQyP-ahpSeW2wDZvn-ljfmsGvN6RTKqo18I6R23ZB3dfbzAnEjvS8tWoPwyH9FFTGifdZ-n_qH80jbRuDbGb0dHu1qEPrLH-vqNq_d6TZdUaC_kZpwvqZnYx"
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
            
            let filteredBusinesses = response.businesses.filter { business in
                        guard let businessRating = business.rating else { return false }
                        return rating == nil || businessRating >= rating!
                    }
            
            DispatchQueue.main.async {
                switch stopType {
                case "Dining":
                    self.restaurants = filteredBusinesses.map { Restaurant(from: $0) }
                case "Hotels":
                    self.hotels = filteredBusinesses.map { Hotel(from: $0) }
                case "Activities":
                    self.activities = filteredBusinesses.map { Activity(from: $0) }
                default:
                    self.generalLocations = filteredBusinesses.map { GeneralLocation(from: $0) }
                }
            }
            print("Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
        } catch {
            print("Error fetching data: \(error.localizedDescription)")
        }
    }

    
    func getCategoryForStopType(stopType: String) -> String {
        switch stopType {
        case "Dining":
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
    
    func getCurrentCity() async {
        let locationManager = CLLocationManager()
        guard let userLocation = locationManager.location else {
            return
        }
        
        let geoCoder = CLGeocoder()
        do {
            if let placemark = try await geoCoder.reverseGeocodeLocation(userLocation).first {
                currentCity = placemark.locality!
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
    
    func populate_my_trips() {
        my_trips = UserViewModel.my_trips
    }
    
    func populate_previous_trips() {
        previous_trips = UserViewModel.previous_trips
    }
    
    func populate_community_trips() {
        community_trips = UserViewModel.community_trips
    }
    
    func updateTrip(trip: Trip) {
        let trip_id = trip.id
        for i in 0..<my_trips.count {
            if my_trips[i].id == trip_id {
                my_trips[i] = trip
                print("updated my_trip \(i)")
                return
            }
        }
        for i in 0..<previous_trips.count {
            if previous_trips[i].id == trip_id {
                previous_trips[i] = trip
                print("updated previous_trips \(i)")
                return
            }
        }
        for i in 0..<community_trips.count {
            if community_trips[i].id == trip_id {
                community_trips[i] = trip
                print("updated community_trips \(i)")
                return
            }
        }
    }
    func getTrip(trip_id: String) -> Trip? {
        for i in 0..<my_trips.count {
            if my_trips[i].id == trip_id {
                print("found my_trip \(i)")
                return my_trips[i]
            }
        }
        for i in 0..<previous_trips.count {
            if previous_trips[i].id == trip_id {
                print("found previous_trips \(i)")
                return previous_trips[i]
            }
        }
        for i in 0..<community_trips.count {
            if community_trips[i].id == trip_id {
                print("found community_trips \(i)")
                return community_trips[i]
            }
        }
        return nil
    }
    
    static let community_trips = [
        Trip(start_location: Activity(address: "555 Favorite Rd", name: "Home", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "666 Favorite Ave", name: "Favorite Hotel 1", latitude: 34.0522, longitude: -118.2437, city: "Redwood"), name: "Redwood National Park", coverImageURL: "https://pixabay.com/get/g673050a33bee3cf92bec894e53c695a132e2a970d4f7d222d78b159fd1104eee8366931c93df76e5a40a270d2511770b03c239fcb15c83fdef1f7fa3e9642b86_640.jpg"),
        Trip(start_location: Restaurant(address: "777 Favorite Rd", name: "Lorum ipsum Pebble Beach", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "888 Favorite Ave", name: "Favorite Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "San Francisco"), name: "LA to SF", coverImageURL: "https://pixabay.com/get/gef59add7afafe4b8e63759d2d0c8508b1f363e38a98223e996dead3532bca58282ea52ed2f01b1279904658ad34fcf6200724f2d7b8d926c60032636ac0868fe_640.jpg"),
        Trip(start_location: Restaurant(address: "333 Old Rd", name: "Lorum Ipsum Pebble Beach, CA", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "444 Old Ave", name: "Previous Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "Boulder"), name: "Colorado Mountains", coverImageURL: "https://pixabay.com/get/g7bac398012f95e6306a5385a0a3e2d7f369e6feee01204d10a6eda3ef233f0f164e517a1e237e85434c9cfb3bf646e4905ed30cc75a5a913e720ad3921599b00_640.jpg")
    ]
    
    static let previous_trips = [
        Trip(start_location: Activity(address: "111 Old Rd", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "222 Old Ave", name: "Previous Hotel 1", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), name: "Cool Restaurants", coverImageURL: "https://pixabay.com/get/g4cbe6d67903fd42c30ee9ac0421be29dcc1f1ff92afca7669ef4d3fd2ff04c1e5aeb563579a1bfa2b531cb31dc3557f2_640.jpg"),
        Trip(start_location: Restaurant(address: "333 Old Rd", name: "Lorum Ipsum Pebble Beach, CA", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "444 Old Ave", name: "Previous Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "Orlando"), name: "ATL to Orlando", coverImageURL: "https://pixabay.com/get/g0802111096a3f85616459fb3973c45a5ad82695ca0d654f73a5c4f1fbb0106fc482049a0bfef0f1fd177ce4dc47b4d9f_640.jpg"),
        Trip(start_location: Restaurant(address: "333 Old Rd", name: "Lorum Ipsum Pebble Beach, CA", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "444 Old Ave", name: "Previous Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "Boston"), name: "Northeast States", coverImageURL: "https://pixabay.com/get/g6c408c1e15343a676c97c97682d0a682a546e589903d30fb298156deaaf4c0a6e8f78818c9de44f1f7a50c36e0f7472bd53e719507d9b106f061e2ec484e28ba_640.jpg")
    ]
    
    static let my_trips = [
        Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville", coverImageURL: "https://pixabay.com/get/g396fa4b9bb9c1731092f12dcf2bb686fc52caaa5dc7a6f7a9edafe2c402bfe67b1a3affcdae0731b43338a151f0d3b21_640.jpg"),
        Trip(start_location: Activity(address: "123 Start St", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Boston"), end_location: Hotel(address: "456 End Ave", name: "End Hotel", latitude: 34.0522, longitude: -118.2437, city: "Seattle"), name: "Cross Country", coverImageURL: "https://pixabay.com/get/g1a5413e9933d659796d14abf3640f03304a18c6867d6a64987aa896e3b6ac83ccc2ac1e5a4a2a7697a92161d1487186b7e2b6d4c17e0f11906a0098eef1da812_640.jpg"),
        Trip(start_location: Activity(address: "789 Another St", name: "Johnson Family Spring Retreat", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "123 Another Ave", name: "Another Hotel", latitude: 34.0522, longitude: -118.2437, city: "Blue Ridge"), name: "GA Mountains", coverImageURL: "https://pixabay.com/get/gceb5f3134c78efcc8fbd206f7fb8520990df3bb7096474f685f8c3cb95749647d5f4752db8cf1521e69fa27b940044b7f477dd18e51de093dd7f79b833ceca1b_640.jpg")
    ]
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
    let categories: [Category]
    let price: String?
    let url: String?
    let image_url: String?
}

struct Location: Codable {
    let address1: String?
    let city: String?
}

struct Coordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct Category: Codable {
    let title: String
}

struct RouteLeg {
    let distance: Double
    let time: Double
}
