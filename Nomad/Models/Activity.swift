//
//  Activity.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/17/24.
//

struct Activity: POI {
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
    
    mutating func setWesite(newWebsite: String) {
        self.website = newWebsite
    }
    
    mutating func setRating(newRating: Double) {
        self.rating = newRating
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
