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
