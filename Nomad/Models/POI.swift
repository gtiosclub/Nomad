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
    var latitude: Double { get set }
    var longitude: Double { get set }
    var city: String? { get set }
    
    mutating func setAddress(newAddress: String)
    mutating func setName(newName: String)
    func getName() -> String
    func getAddress() -> String
    
    mutating func setLatitude(newLatitude: Double)
    mutating func setLongitude(newLongitude: Double)
    func getLatitude() -> Double
    func getLongitude() -> Double
    
    mutating func setCity(newCity: String)
    func getCity() -> String?
}

protocol Ratable {
    var rating: Double? { get set }
    
    mutating func setRating(newRating: Double)
    func getRating() -> Double
}

protocol Imagable {
    var imageUrl: String? { get set }

    func getImageUrl() -> String?
    
}
