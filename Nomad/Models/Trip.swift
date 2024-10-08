//
//  Trip.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

struct Trip: Identifiable, Equatable {
    var id: String
    private var stops: [any POI]
    private var start_location: any POI
    private var end_location: any POI
    private var start_date: String
    private var end_date: String
    private var created_date: String
    private var modified_date: String
    private var start_time: String

    
    init(start_location: any POI, end_location: any POI, start_date: String = "", end_date: String = "", stops: [any POI] = [], start_time: String = "8:00 AM") {
        self.stops = stops
        self.start_location = start_location
        self.end_location = end_location
        self.start_date = start_date
        self.end_date = end_date
        self.id = UUID().uuidString
        self.created_date = Trip.getCurrentDateTime()
        self.modified_date = self.created_date
        self.start_time = start_time
    }
    
    init(id: String, start_location: any POI, end_location: any POI, start_date: String, end_date: String, stops: [any POI], start_time: String, created_date: String, modified_date: String) {
        self.stops = stops
        self.start_location = start_location
        self.end_location = end_location
        self.start_date = start_date
        self.end_date = end_date
        self.id = id
        self.created_date = created_date
        self.modified_date = modified_date
        self.start_time = start_time
    }
    
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        return lhs.id == rhs.id && lhs.modified_date == rhs.modified_date
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
    
    mutating func setStartLocation(new_start_location: any POI) {
        self.start_location = new_start_location
        self.updateModifiedDate()
    }
    
    mutating func setEndLocation(new_end_location: any POI) {
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
    
    mutating func setStartTime(newTime: String) {
        self.start_time = newTime
        self.updateModifiedDate()
    }
    
    mutating func addStops(additionalStops: [any POI]) {
        self.stops.append(contentsOf: additionalStops)
        self.updateModifiedDate()
    }
    
    mutating func removeStops(removedStops: [any POI]) {
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
}
