//
//  MapMarker.swift
//  Nomad
//
//  Created by Nicholas Candello on 10/4/24.
//
import Foundation
import MapKit
import CoreLocation

struct MapMarker: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let icon: MapMarkerIcon
    
    init(coordinate: CLLocationCoordinate2D, title: String, icon: MapMarkerIcon) {
        self.coordinate = coordinate
        self.title = title
        self.icon = icon
    }
    
    init(coordinate: CLLocationCoordinate2D, title: String) {
        self.init(coordinate: coordinate, title: title, icon: .pin)
    }
    
    enum MapMarkerIcon: Int {
        case pin, restaurant, hotel, museum, park, trafficLight, stopSign // placeholders for now
        
        var image_path: String {
            switch self {
            case .pin:
                return "pin.fill"
            case .restaurant:
                return "restaurant"
            case .hotel:
                return "hotel"
            case .museum:
                return "museum"
            case .park:
                return "park"
            case .trafficLight:
                return "traffic_light_icon"
            case .stopSign:
                return "stop_sign_icon"
            }
        }
    }
}
