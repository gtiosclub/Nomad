//
//  GeneralLocation.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/22/24.
//

import Foundation

struct GeneralLocation: POI, Identifiable {
    var id: String
    var address: String
    var name: String
    var imageUrl: String?
    
    init(address: String, name: String) {
        self.id = UUID().uuidString
        self.address = address
        self.name = name
    }
    
    init(from business: Business) {
        self.id = business.id
        self.address = business.location.address1 ?? "No address"
        self.name = business.name
        self.imageUrl = business.image_url
    }
    
    mutating func setAddress(newAddress: String) {
        self.address = newAddress
    }
    
    mutating func setName(newName: String) {
        self.name = newName
    }
    
    func getAddress() -> String {
        return address
    }
    
    func getName() -> String {
        return name
    }
}
