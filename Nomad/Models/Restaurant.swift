//
//  Restaurant.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

struct Restaurant: POI, Identifiable {
    var id: String
    var address: String
    var name: String
    var rating: Double?
    var cuisine: String?
    var price: Int?
    var website: String?
    var longitude: Double?
    var latitude: Double?

    init(address: String, name: String, rating: Double? = nil, cuisine: String? = nil, price: Int? = nil, website: String? = nil, latitude: Double? = nil, longitude: Double? = nil) {
        self.id = UUID().uuidString
        self.address = address
        self.name = name
        self.rating = rating
        self.cuisine = cuisine
        self.price = price
        self.website = website
        self.latitude = latitude
        self.longitude = longitude
    }

    init(from business: Business) {
        self.id = business.id
        self.address = business.location.address1 ?? "No address"
        self.name = business.name
        self.rating = business.rating
        self.cuisine = business.categories.first?.title
        self.price = business.price?.count
        self.website = business.url
        self.latitude = business.coordinates.latitude
        self.longitude = business.coordinates.longitude
    }
    
    static func == (lhs: Restaurant, rhs: Restaurant) -> Bool {
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
    
    mutating func setCuisine(newCuisine: String) {
        self.cuisine = newCuisine
    }
    
    mutating func setPrice(newPrice: Int) {
        self.price = newPrice
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

    func getAddress() -> String {
        return address
    }
    
    func getName() -> String {
        return name
    }
    
    func getRating() -> Double {
        return rating ?? 0
    }
    
    func getCuisine() -> String {
        return cuisine ?? ""
    }
    
    func getPrice() -> Int {
        return price ?? 0
    }
    
    func getWebsite() -> String {
        return website ?? ""
    }
    
    func getLongitude() -> Double? {
        return longitude
    }
    
    func getLatitude() -> Double? {
        return latitude
    }
}
