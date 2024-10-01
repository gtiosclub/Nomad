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
    
    func getTrips() -> [Trip] {
        return user?.getTrips() ?? []
    }
    
    func addStop(stop: POI) {
        current_trip?.addStops(additionalStops: [stop])
        user?.updateTrip(trip: current_trip.self)
        self.user = user
    }
    
    func removeStop(stop: POI) {
        current_trip?.removeStops(removedStops: [stop])
        user?.updateTrip(trip: current_trip.self)
        self.user = user
    }
    
    func setCurrentTrip(trip: Trip) {
        self.current_trip = trip
    }
    
    func setStartLocation(new_start_location: POI) {
        current_trip?.setStartLocation(new_start_location: new_start_location)
        user?.updateTrip(trip: current_trip.self)
        self.user = user
    }
    
    func setEndLocation(new_end_location: POI) {
        current_trip?.setEndLocation(new_end_location: new_end_location)
        user?.updateTrip(trip: current_trip.self)
        self.user = user
    }
    
    func setTripStartDate(startDate: String) {
        current_trip?.setStartDate(newDate: startDate)
        user?.updateTrip(trip: current_trip.self)
        self.user = user
    }
    
    func setTripEndDate(endDate: String) {
        current_trip?.setEndDate(newDate: endDate)
        user?.updateTrip(trip: current_trip.self)
        self.user = user
    }
    
    func setCurrentTrip(by tripID: String) {
        guard let user = user else {return}
        
        if let trip = user.findTrip(id: tripID) {
            current_trip = trip
        }
    }
}
    
