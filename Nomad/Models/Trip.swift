//
//  Trip.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import MapKit

class Trip: Identifiable, Equatable, ObservableObject {
    var id: String
    var route: NomadRoute?
    private var stops: [any POI]
    private var start_location: any POI
    private var end_location: any POI
    private var start_date: String
    private var end_date: String
    private var created_date: String
    @Published var modified_date: String
    private var start_time: String
    @Published var coverImageURL: String
    @Published var name: String
    var isPrivate: Bool = true

    init(route: NomadRoute? = nil, start_location: any POI, end_location: any POI, start_date: String = "", end_date: String = "", stops: [any POI] = [], start_time: String = "8:00 AM", name: String = "", coverImageURL: String = "") {
        self.route = route
        self.stops = stops
        self.start_location = start_location
        self.end_location = end_location
        self.start_date = start_date
        self.end_date = end_date
        self.id = UUID().uuidString
        self.created_date = Trip.getCurrentDateTime()
        self.modified_date = self.created_date
        self.start_time = start_time
        self.coverImageURL = coverImageURL
        self.name = name
        if coverImageURL.isEmpty {
            print("find image for \(end_location.name)")
            Trip.getCityImage(location: end_location) { imageURL in
                DispatchQueue.main.async {
                    self.coverImageURL = imageURL
                    self.updateModifiedDate()
                }
            }
        }
//        if coverImageURL.isEmpty {
//            Task {
//                self.coverImageURL = await Trip.getCityImageAsync(location: end_location)
//            }
//        }
    }
    
//    func generateRoute() async {
//        var pois = [self.getStartLocation()]
//        pois.append(contentsOf: self.getStops())
//        pois.append(self.getEndLocation())
//        if let routes = await RootView.mapManager.generateRoute(pois: pois) {
//            self.setRoute(route: routes[0]) // set main route
//        }
//    }
//    
//    func setCoverImageURL(newURL: String) {
//        self.coverImageURL = newURL
//        self.updateModifiedDate()
//    }
    
    @MainActor
    static func getCityImageAsync(location: any POI) async -> String {
        var search_city: String = ""
        if let city = location.getCity() {
            search_city = city
        } else {
            let location_split = location.getAddress().split(separator: ",")
            if location_split.count > 1 {
                search_city = location_split[1].description
            }
        }
        
        let urlString = "https://pixabay.com/api/?key=46410552-0c1561d54d98701d038092a47&q=\(search_city)-city-scenic&image_type=photo"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return ""
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        struct PixabayResponse: Codable {
            let hits: [PixabayPhoto]
        }

        struct PixabayPhoto: Codable {
            let id: Int
            let webformatURL: String
        }
        
        do {
            // Use async/await to fetch data
            let (data, _) = try await URLSession.shared.data(for: request)
            
            // Decode the response data
            let pixabayResponse = try JSONDecoder().decode(PixabayResponse.self, from: data)
            let firstImageURL = pixabayResponse.hits.first?.webformatURL ?? ""
            
            return firstImageURL
        } catch {
            print("Error fetching or decoding data: \(error)")
            return ""
        }
    }
    
    static func getCityImage(location: any POI, completion: @escaping (String) -> Void) {
        var search_city: String = ""
        if let city = location.getCity() {
            search_city = city
        } else {
            let location_split = location.getAddress().split(separator: ",")
            if location_split.count > 1 {
                search_city = location_split[1].description
            }
        }
        
        let url = URL(string: "https://pixabay.com/api/?key=46410552-0c1561d54d98701d038092a47&q=\(search_city)-city-GA-scenic&image_type=photo")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        struct PixabayResponse: Codable {
            let hits: [PixabayPhoto]
        }
        
        struct PixabayPhoto: Codable {
            let id: Int
            let webformatURL: String
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                completion("")
                return
            }
            
            guard let data = data else {
                print("No data returned")
                completion("")
                return
            }
            
            do {
                let pixabayResponse = try JSONDecoder().decode(PixabayResponse.self, from: data)
                let hits = pixabayResponse.hits
                let firstImageURL = hits.first?.webformatURL ?? ""
                print("Found image for \(search_city): \(firstImageURL)")
                DispatchQueue.main.async {
                    completion(firstImageURL)
                }
            } catch {
                print("Failed to decode JSON: \(error)")
            }
        }.resume()
    }
    
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        return lhs.id == rhs.id && lhs.modified_date == rhs.modified_date
    }
    
    func updateModifiedDate() {
        self.modified_date = Trip.getCurrentDateTime()
    }
    
    static func getCurrentDateTime() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        return dateFormatter.string(from: currentDate)
    }
    
    func setStartLocation(new_start_location: any POI) {
        self.start_location = new_start_location
        self.updateModifiedDate()
    }
    
    func setEndLocation(new_end_location: any POI) {
        self.end_location = new_end_location
        self.updateModifiedDate()
//        Trip.getCityImage(location: new_end_location) { [self] imageURL in
//            self.coverImageURL = imageURL
//        }
    }
    
    func setStartDate(newDate: String) {
        self.start_date = newDate
        self.updateModifiedDate()
    }
    
    func setEndDate(newDate: String) {
        self.end_date = newDate
        self.updateModifiedDate()
    }
    
    func setStartTime(newTime: String) {
        self.start_time = newTime
        self.updateModifiedDate()
    }
    
    func addStops(additionalStops: [any POI]) {
        self.stops.append(contentsOf: additionalStops)
        self.updateModifiedDate()
    }
    
    func addStopAtIndex(newStop: any POI, index: Int) {
        self.stops.insert(newStop, at: index)
        self.updateModifiedDate()
    }
    
    func removeStops(removedStops: [any POI]) {
        self.stops.removeAll { stop in
            removedStops.contains(where: { $0.name == stop.name })
        }
        self.updateModifiedDate()
    }
    
    func getStops() -> [any POI] {
        return stops
    }

    func getStartLocation() -> any POI {
        return start_location
    }

    func getEndLocation() -> any POI {
        return end_location
    }

    func getStartDate() -> String? {
        return start_date
    }

    func getEndDate() -> String? {
        return end_date
    }
    
    func getStartTime() -> String? {
        return start_time
    }

    func duplicate() -> Trip {
        return Trip(start_location: start_location, end_location: end_location, start_date: start_date, end_date: end_date, stops: stops)
    }
    
    func setRoute(route: NomadRoute) {
        self.route = route
    }
    
    func getRoute() -> NomadRoute? {
        return route
    }

    func getCoverImageURL() -> String {
        coverImageURL
    }
    
    func getName() -> String {
        return name.isEmpty ? "Unnamed Trip" : name
    }

    func setName(newName: String) {
        self.name = newName
    }

    func setIsPrivate() -> Bool {
        return isPrivate
    }

    func setVisibility(isPrivate: Bool) {
        self.isPrivate = isPrivate
    }
  
    func getStartLocationCoordinates() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: start_location.latitude, longitude: start_location.longitude)
    }
    
    func getEndLocationCoordinates() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: end_location.latitude, longitude: end_location.longitude)
    }
    
    mutating func reorderStops(fromOffsets: IndexSet, toOffset: Int) {
        stops.move(fromOffsets: fromOffsets, toOffset: toOffset)
    }
}
