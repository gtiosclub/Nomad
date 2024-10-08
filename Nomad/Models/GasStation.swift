//
//  GasStation.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

struct GasStation: POI {
    var name: String
    var address: String
    
    mutating func setAddress(newAddress: String) {
        self.address = newAddress
    }
    
    mutating func setName(newName: String) {
        self.name = newName
    }
    
    func getAddress() -> String {
        address
    }
    
    func getName() -> String {
        name
    }
}
