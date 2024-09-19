//
//  Hotel.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/17/24.
//

struct Hotel: POI {
    var address: String
    var name: String
    var rating: Double?
    var website: String?

    init(address: String, name: String, rating: Double? = nil, website: String? = nil) {
        self.address = address
        self.name = name
        self.rating = rating
        self.website = website
    }

    mutating func setAddress(newAddress: String) {
        self.address = newAddress
    }
    
    mutating func setName(newName: String) {
        self.name = newName
    }
    
    mutating func setRating(newRating: Double?) {
        self.rating = newRating
    }
    
    mutating func setWebsite(newWebsite: String?) {
        self.website = newWebsite
    }

    func getAddress() -> String {
        return self.address
    }
    
    func getName() -> String {
        return self.name
    }
    
    func getRating() -> Double? {
        return self.rating
    }
    
    func getWebsite() -> String? {
        return self.website
    }
}

