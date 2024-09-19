//
//  Trip.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

struct Trip {
    var stops: [POI]
    var start_location: POI
    var end_location: POI
    var start_date: String?
    var end_date: String?
    
    init(stops: [POI], start_location: POI, end_location: POI, start_date: String? = nil, end_date: String? = nil) {
        self.stops = stops
        self.start_location = start_location
        self.end_location = end_location
        self.start_date = start_date
        self.end_date = end_date
    }
    
    
    mutating func setStartLocation(new_start_location: POI) {
        self.start_location = new_start_location
    }
    mutating func setEndLocation(new_end_location: POI) {
        self.end_location = new_end_location
    }
    
    mutating func addStops(additionalStops: [POI]) {
        self.stops.append(contentsOf: additionalStops)
    }
    mutating func removeStops(removedStops: [POI]) {
        self.stops.removeAll { stop in
            removedStops.contains(where: { $0.name == stop.name })
        }
    }
}
