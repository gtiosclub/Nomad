//
//  Activity.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/17/24.
//

import Foundation

struct Activity: POI, Identifiable, Ratable {
    var id: String
    var address: String
    var name: String
    var rating: Double?
    var website: String?
    var longitude: Double?
    var latitude: Double?

    init(address: String, name: String, rating: Double? = nil, website: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = UUID().uuidString
        self.address = address
        self.name = name
        self.rating = rating
        self.website = website
        self.latitude = latitude
        self.longitude = longitude
    }

    init(from business: Business) {
        self.id = business.id
        self.address = business.location.address1 ?? "No address"
        self.name = business.name
        self.rating = business.rating
        self.website = business.url
        self.latitude = business.coordinates.latitude
        self.longitude = business.coordinates.longitude
    }
    
    static func == (lhs: Activity, rhs: Activity) -> Bool {
        return lhs.name == rhs.name && lhs.address == rhs.address
    }

    mutating func setAddress(newAddress: String) {
        self.address = newAddress
    }

    mutating func setName(newName: String) {
        self.name = newName
    }

    mutating func setWebsite(newWebsite: String?) {
        self.website = newWebsite
    }

    mutating func setRating(newRating: Double) {
        self.rating = newRating
    }
    
    mutating func setLongitude(newLongitude: Double) {
        self.longitude = newLongitude
    }
    
    mutating func setLatitude(newLatitude: Double) {
        self.latitude = newLatitude
    }

    func getAddress() -> String {
        return self.address
    }

    func getName() -> String {
        return self.name
    }

    func getRating() -> Double {
        return self.rating ?? 0
    }

    func getWebsite() -> String {
        return self.website ?? ""
    }
    
    func getLongitude() -> Double? {
        return longitude
    }
    
    func getLatitude() -> Double? {
        return latitude
    }
}
