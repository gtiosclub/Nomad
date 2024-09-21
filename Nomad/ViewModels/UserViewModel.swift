//
//  UserViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import MapKit
// start loc, end loc assign that to the users trips list
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var current_trip: Trip?
    
    func createTrip(start: POI, end: POI){
        current_trip = Trip(start_location: start, end_location: end)
    }
        
    func addTripToUser(trip: Trip){
        if var user = user {
            user.addTrip(trip: trip)
        }
    }
        
    //take in POI and add that to a trip within a user
    func addStop(stop: POI) {
        current_trip?.addStops(additionalStops: [stop])
    }
}

