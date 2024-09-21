//
//  User.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

struct User: Identifiable {
    var id: String
    var trips: [Trip]?
    
    init(id: String, trips: [Trip]? = []) {
        self.id = id
        self.trips = trips
    }
    
    mutating func addTrip(trip: Trip){
        if self.trips == nil {
            self.trips = []
        }
        self.trips?.append(trip)
    }
    
    func getTrips() -> [Trip] {
        if self.trips == nil {
            return []
        }
        return self.trips!
    }
}

