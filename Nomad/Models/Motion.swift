//
//  Motion.swift
//  Nomad
//
//  Created by Rudra Amin on 9/19/24.
//

import Foundation
import CoreLocation

struct Motion {
    var coordinate: CLLocationCoordinate2D?
    var direction: CLLocationDirection?
    var altitude: CLLocationDistance?
    var speed: CLLocationSpeed?
    
    func toString() -> String {
        return "latitude: \(coordinate?.latitude.description ?? "ERROR"), longitude: \(coordinate?.longitude.description ?? "ERROR"), direction: \(direction?.description ?? "ERROR"), altitude: \(altitude?.description ?? "ERROR"), speed: \(speed?.description ?? "ERROR")"
    }
}
