//
//  User.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

struct User: Identifiable {
    var id: String
    var trips: [Trip]
    
    mutating func addTrip(trip: Trip){
        self.trips.append(trip)
    }
}

