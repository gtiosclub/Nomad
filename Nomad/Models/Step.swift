//
//  Step.swift
//  Nomad
//
//  Created by Vignesh Suresh Kumar on 10/1/24.
//

import MapKit
import MapboxDirections

struct NomadRoute {
    let id = UUID()
    var route: Route
    var steps: [Step]
}
struct Step {
    let id = UUID()
    
    struct Direction {
        var distance: CLLocationDistance
        var instructions: String
        var expectedTravelTime: TimeInterval
    }
    
    struct Exit {
        var destinations: [String]? // Control cities on exit board
        var exitCodes: [String]? // Exit numbers associated with highway number
        var exitNames: [String]? // Names at roundabout exit
    }
    
    var routeShape: MKPolyline
    var startCoordinate: CLLocationCoordinate2D?
    var endCoordinate: CLLocationCoordinate2D?
    var direction: Direction
    var exit: Exit?
    
    
    init(step: RouteStep) {
        self.startCoordinate = step.shape?.coordinates.first
        self.endCoordinate = step.shape?.coordinates.first
        self.routeShape = Step.convertToMKPolyline(step.shape?.coordinates ?? [])
        self.direction = Direction(distance: step.distance, instructions: step.instructions, expectedTravelTime: step.expectedTravelTime)
        if step.destinations != nil || step.exitCodes != nil || step.exitNames != nil {
            self.exit = Exit(destinations: step.destinations, exitCodes: step.exitCodes, exitNames: step.exitNames)
        } else {
            self.exit = nil
        }
    }
    
    static func convertToMKPolyline(_ coords: [LocationCoordinate2D]) -> MKPolyline {
        var coordinates = [CLLocationCoordinate2D]()
        for coord in coords {
            coordinates.append(CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude))
        }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
}
