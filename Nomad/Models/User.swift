//
//  User.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

class User: Identifiable, ObservableObject {
    var id: String
    private var name: String
    var email: String
//    var profilePicture: String
    @Published var trips: [Trip] // this is referencing future trips
    @Published var pastTrips: [Trip]
    @Published var currentTrip: [Trip]
    
    init(id: String, name: String, email: String = "", trips: [Trip] = [], pastTrips: [Trip] = [], currentTrip: [Trip] = []) {
        self.id = id
        self.name = name
        self.email = email
//        self.profilePicture = profilePicture
        self.trips = trips
        self.pastTrips = pastTrips
        self.currentTrip = currentTrip
    }
    
    func getName() -> String {
        return self.name
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
    
    func updateTrip(trip: Trip?) {
        if trip == nil { return }
        let index: Int? = self.trips.firstIndex(where: { $0.id == trip?.id })
        if index == nil { return }
        self.trips[index!] = trip!
    }
}

