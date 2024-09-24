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
    
    init(user: User? = nil) {
        self.user = user
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    func createNewUser(name: String) {
        self.user = User(id: UUID().uuidString, name: name)
    }
    
    func createTrip(start: POI, end: POI) -> Trip {
        self.current_trip = Trip(start_location: start, end_location: end)
        return current_trip!
    }
        
    func addTripToUser(trip: Trip){
        if let user = user {
            user.addTrip(trip: trip)
            objectWillChange.send() 
        }
    }
        
    func addStop(stop: POI) {
        current_trip?.addStops(additionalStops: [stop])
    }
    
    func getTrips() -> [Trip] {
        return user?.trips ?? []
    }
    
    func removeStop(stop: POI) {
        current_trip?.removeStops(removedStops: [stop])
    }
    
    func setCurrentTrip(trip: Trip) {
        self.current_trip = trip
    }
    
    func setStartLocation(new_start_location: POI) {
        if var trip = current_trip {
            trip.setStartLocation(new_start_location: newStartLocation)
            
        }
        
        if var user = user, let tripIndex = user.findTrip(id: current_trip?.id) {
            user.trips[tripIndex].setStartLocation(new_start_location: newStartLocation)
        }
                        
        self.user = user
    }
    
    func setEndLocation(new_end_location: POI) {
        if var trip = current_trip {
            trip.setEndLocation(new_end_location: newEndLocation)
            
        }
        
        if var user = user, let tripIndex = user.findTrip(id: current_trip?.id) {
            user.trips[tripIndex].setEndLocation(new_end_location: newEndLocation)
        }
                        
        self.user = user
    }
}

