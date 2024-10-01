//
//  Hotel.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/17/24.
//

import Foundation

struct Hotel: POI, Identifiable {
    var id: String
    var address: String
    var name: String
    var rating: Double?
    var website: String?

    init(address: String, name: String, rating: Double? = nil, website: String? = nil) {
        self.id = UUID().uuidString
        self.address = address
        self.name = name
        self.rating = rating
        self.website = website
    }
    
    init(from business: Business) {
        self.id = business.id
        self.address = business.location.address1 ?? "No address"
        self.name = business.name
        self.rating = business.rating
        self.website = business.url
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
    
    func getRating() -> Double {
        return self.rating ?? 0
    }
    
    func getWebsite() -> String {
        return self.website ?? ""
    }
}

