//
//  Hotel.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/17/24.
//

import Foundation

struct Hotel: POI, Identifiable, Ratable, Imagable {
    var id: String
    var address: String
    var name: String
    var rating: Double?
    var website: String?
    var imageUrl: String?
    var longitude: Double
    var latitude: Double
    var city: String?

    init(address: String, name: String, rating: Double? = nil, website: String? = nil, latitude: Double, longitude: Double, city: String? = nil) {
        self.id = UUID().uuidString
        self.address = address
        self.name = name
        self.rating = rating
        self.website = website
        self.latitude = latitude
        self.longitude = longitude
        self.city = city
    }
    
    init(from business: Business) {
        self.id = business.id
        self.address = business.location.display_address.joined(separator: ", ")
        self.name = business.name
        self.rating = business.rating
        self.website = business.url
        self.imageUrl = business.image_url
        self.latitude = business.coordinates.latitude
        self.longitude = business.coordinates.longitude
        self.city = business.location.city
    }
    
    static func == (lhs: Hotel, rhs: Hotel) -> Bool {
        return lhs.name == rhs.name && lhs.address == rhs.address
    }
    
    mutating func setAddress(newAddress: String) {
        self.address = newAddress
    }
    
    mutating func setName(newName: String) {
        self.name = newName
    }
    
    mutating func setRating(newRating: Double) {
        self.rating = newRating
    }
    
    mutating func setWebsite(newWebsite: String?) {
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
    
    mutating func setImageUrl(newUrl: String) {
        self.imageUrl = newUrl
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
    
    func getLongitude() -> Double {
        return longitude
    }
    
    func getLatitude() -> Double {
        return latitude
    }
    
    func getCity() -> String? {
        return city
    }
    
    func getImageUrl() -> String? {
        return imageUrl
    }
    
    func getId() -> String {
        return id
    }
}

