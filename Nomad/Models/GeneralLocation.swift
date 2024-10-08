//
//  GeneralLocation.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/22/24.
//

import Foundation

struct GeneralLocation: POI, Identifiable {
    var id: String
    var address: String
    var name: String
    var longitude: Double?
    var latitude: Double?
    
    init(address: String, name: String, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = UUID().uuidString
        self.address = address
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    init(from business: Business) {
        self.id = business.id
        self.address = business.location.address1 ?? "No address"
        self.name = business.name
        self.latitude = business.coordinates.latitude
        self.longitude = business.coordinates.longitude
    }
    
    static func == (lhs: GeneralLocation, rhs: GeneralLocation) -> Bool {
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
        return address
    }
    
    func getName() -> String {
        return name
    }
    
    func getLongitude() -> Double? {
        return longitude
    }
    
    func getLatitude() -> Double? {
        return latitude
    }
}
