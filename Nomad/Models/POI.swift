//
//  POI.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

protocol POI {
    var address: String { get set }
    var name: String { get set }
    
    mutating func setAddress(newAddress: String)
    mutating func setName(newName: String)
}
