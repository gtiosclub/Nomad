//
//  GasStation.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

struct GasStation: POI {
    var name: String
    var address: String
    var longitude: Double?
    var latitude: Double?
    
    static func == (lhs: GasStation, rhs: GasStation) -> Bool {
        return lhs.name == rhs.name && lhs.address == rhs.address
    }
    
    mutating func setAddress(newAddress: String) {
        self.address = newAddress
    }
    
    mutating func setName(newName: String) {
        self.name = newName
    }
    
    mutating func setLongitude(newLongitude: Double) {
        self.longitude = newLongitude
    }
    
    mutating func setLatitude(newLatitude: Double) {
        self.latitude = newLatitude
    }
    
    func getAddress() -> String {
        address
    }
    
    func getName() -> String {
        name
    }
    
    func getLongitude() -> Double? {
        return longitude
    }
    
    func getLatitude() -> Double? {
        return latitude
    }
}
