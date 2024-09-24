//
//  GeneralLocation.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/22/24.
//

import Foundation

struct GeneralLocation: POI {
    var address: String
    var name: String
    
    init(address: String, name: String) {
        self.address = address
        self.name = name
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
