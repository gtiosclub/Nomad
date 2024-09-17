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
    
    init(address: String, name: String, rating: Double? = nil) {
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
}
