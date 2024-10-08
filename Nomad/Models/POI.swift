//
//  POI.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation

protocol POI: Equatable {
    var address: String { get set }
    var name: String { get set }
    var latitude: Double? { get set }
    var longitude: Double? { get set }
    
    mutating func setAddress(newAddress: String)
    mutating func setName(newName: String)
    func getName() -> String
    func getAddress() -> String
    
    mutating func setLatitude(newLatitude: Double)
    mutating func setLongitude(newLongitude: Double)
    func getLatitude() -> Double?
    func getLongitude() -> Double?
}
