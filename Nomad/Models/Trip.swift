//
//  Trip.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

struct Trip: Identifiable {
    var id: String
    var stops: [POI]
    var start_location: POI
    var end_location: POI
    var start_date: String
    var end_date: String
    var created_date: String
    var modified_date: String

    
    init(start_location: POI, end_location: POI, start_date: String = "", end_date: String = "", stops: [POI] = []) {
        self.stops = stops
        self.start_location = start_location
        self.end_location = end_location
        self.start_date = start_date
        self.end_date = end_date
        self.id = UUID().uuidString
        self.created_date = Trip.getCurrentDateTime()
        self.modified_date = self.created_date
    }
    
    mutating func updateModifiedDate() {
        self.modified_date = Trip.getCurrentDateTime()
    }
    
    static func getCurrentDateTime() -> String {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        return dateFormatter.string(from: currentDate)
    }
    
    mutating func setStartLocation(new_start_location: POI) {
        self.start_location = new_start_location
        self.updateModifiedDate()
    }
    
    mutating func setEndLocation(new_end_location: POI) {
        self.end_location = new_end_location
        self.updateModifiedDate()
    }
    
    mutating func setStartDate(newDate: String) {
        self.start_date = newDate
        self.updateModifiedDate()
    }
    
    mutating func setEndDate(newDate: String) {
        self.end_date = newDate
        self.updateModifiedDate()
    }
    
    mutating func addStops(additionalStops: [POI]) {
        self.stops.append(contentsOf: additionalStops)
        self.updateModifiedDate()
    }
    
    mutating func removeStops(removedStops: [POI]) {
        self.stops.removeAll { stop in
            removedStops.contains(where: { $0.name == stop.name })
        }
        self.updateModifiedDate()
    }
    
    func getStops() -> [POI] {
        return stops
    }

    func getStartLocation() -> POI {
        return start_location
    }

    func getEndLocation() -> POI {
        return end_location
    }

    func getStartDate() -> String? {
        return start_date
    }

    func getEndDate() -> String? {
        return end_date
    }

    func duplicate() -> Trip {
        return Trip(start_location: start_location, end_location: end_location, start_date: start_date, end_date: end_date, stops: stops)
    }
}
