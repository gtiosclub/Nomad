//
//  UserViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import MapKit

class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var current_trip: Trip?
    
    init(user: User) {
        self.user = user
    }
    
    //take in POI and add that to a trip within a user
    func addStop(stop: POI) {
        current_trip?.addStops(additionalStops: [stop])
    }
}

