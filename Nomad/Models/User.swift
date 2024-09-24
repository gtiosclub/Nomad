//
//  User.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

class User: Identifiable {
    var id: String
    private var name: String
    private var trips: [Trip]
    
    init(id: String, name: String, trips: [Trip] = []) {
        self.id = id
        self.name = name
        self.trips = trips
    }
    
    func addTrip(trip: Trip) {
        self.trips.append(trip)
    }
    
    func getTrips() -> [Trip] {
        return self.trips
    }
    
    func findTrip(id: String) -> Trip? {
        return self.trips.first(where: { $0.id == id })
    }
}

