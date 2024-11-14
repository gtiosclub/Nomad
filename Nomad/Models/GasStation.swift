//
//  GasStation.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

struct GasStation: POI, Imagable, Identifiable {
    var id: String
    var name: String
    var address: String
    var longitude: Double
    var latitude: Double
    var city: String?
    var imageUrl: String?
    
    init(address: String, name: String, latitude: Double, longitude: Double, city: String? = nil, imageURL: String? = nil) {
        self.id = UUID().uuidString
        self.address = address
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
        self.imageUrl = imageURL
    }
    
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
    
    mutating func setCity(newCity: String) {
        self.city = newCity
    }
    
    func getAddress() -> String {
        return address
    }
    
    func getName() -> String {
        return name
    }
    
    func getLongitude() -> Double {
        return longitude
    }
    
    func getLatitude() -> Double {
        return latitude
    }
    
    func getCity() -> String? {
        return city
    }
    
    func getId() -> String {
        return id
    }
    
    func getImageUrl() -> String? {
        return imageUrl
    }

}
