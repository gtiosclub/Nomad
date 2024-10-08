//
//  RestStop.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

struct RestStop: POI {
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

