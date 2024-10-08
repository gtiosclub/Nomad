//
//  GeneralLocation 2.swift
//  Nomad
//
//  Created by Brayden Huguenard on 10/1/24.
//


import Foundation

struct GeneralLocation: POI, Identifiable {
    var id: String
    var address: String
    var name: String

    init(address: String, name: String) {
        self.id = UUID().uuidString
        self.address = address
        self.name = name
    }

    // Mutating functions to set properties
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

// Example of using GeneralLocation
let location = GeneralLocation(address: "123 Main St, Atlanta, GA", name: "Sample Location")
print("Location: \(location.getName()), Address: \(location.getAddress())")
