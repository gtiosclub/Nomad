//
//  Restaurant.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

struct Restaurant: POI {
    var address: String
    var name: String
    var rating: Double?
    var cuisine: String?
    var price: Int?
    var website: String?
    
    init(address: String, name: String, rating: Double? = nil, cuisine: String? = nil, price: Int? = nil, website: String? = nil) {
        self.address = address
        self.name = name
        self.rating = rating
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
    
    func getAddress() -> String {
        address
    }
    
    func getName() -> String {
        name
    }
    
    func getRating() -> Double {
        rating ?? 0
    }
    
    func getCuisine() -> String {
        cuisine ?? ""
    }
    
    func getPrice() -> Int {
        price ?? 0
    }
    
    func getWebsite() -> String {
        website ?? ""
    }
}
