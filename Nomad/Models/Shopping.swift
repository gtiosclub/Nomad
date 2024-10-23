//
//  Shopping.swift
//  Nomad
//
//  Created by Brayden Huguenard on 10/22/24.
//

import Foundation

struct Shopping: POI, Identifiable {
    var id: String
    var address: String
    var name: String
    var website: String?
    var imageUrl: String?
    var open_time: String?
    var close_time: String?
    var longitude: Double
    var latitude: Double
    var city: String?

    init(address: String, name: String, website: String? = nil, latitude: Double, longitude: Double, city: String? = nil) {
        self.id = UUID().uuidString
        self.address = address
        self.name = name
        self.website = website
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
    }

    init(from business: Business) {
        self.id = business.id
        self.address = business.location.display_address.joined(separator: ", ")
        self.name = business.name
        self.website = business.url
        self.imageUrl = business.image_url
        self.latitude = business.coordinates.latitude
        self.longitude = business.coordinates.longitude
        self.city = business.location.city
    }
    
    static func == (lhs: Shopping, rhs: Shopping) -> Bool {
        return lhs.name == rhs.name && lhs.address == rhs.address
    }

    mutating func setAddress(newAddress: String) {
        self.address = newAddress
    }
    
    mutating func setName(newName: String) {
        self.name = newName
    }
    
    mutating func setWebsite(newWebsite: String) {
        self.website = newWebsite
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
    
    func getWebsite() -> String {
        return website ?? ""
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
}
