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
    var route: Route?
    var legs: [NomadLeg]
    
    // returns an array of polylines for each step of the route.
    func getRoutePolyline() -> MKPolyline {
        var all_coords = [CLLocationCoordinate2D]()
        if let shape = route?.shape?.coordinates {
            for coord in shape {
                all_coords.append(CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude))
            }
        }
        let polyline = MKPolyline(coordinates: all_coords, count: all_coords.count)
        return polyline
    }
    
//    func getStartLocation() -> CLLocationCoordinate2D? {
//        return steps[0].startCoordinate
//    }
//    
//    func getEndLocation() -> CLLocationCoordinate2D? {
//        steps[steps.count - 1].endCoordinate
//    }
    static func convertToMKPolyline(_ coords: [LocationCoordinate2D]) -> MKPolyline {
        var coordinates = [CLLocationCoordinate2D]()
        for coord in coords {
            coordinates.append(CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude))
        }
        return MKPolyline(coordinates: coordinates, count: coordinates.count)
    }
}

struct NomadLeg {
    let id = UUID()
    var steps: [Step]
    var startCoordinate: CLLocationCoordinate2D
    var endCoordinate: CLLocationCoordinate2D
    var routeShape: MKPolyline
    private var coords: [CLLocationCoordinate2D]
    
    init(leg: MapboxDirections.RouteLeg) {
        
    }
    
    init(steps: [NomadStep]) {
        
    }
    func getStartLocation() -> CLLocationCoordinate2D {
        return startCoordinate
    }
    func getEndLocation() -> CLLocationCoordinate2D {
        return endCoordinate
    }
    
    func getShape() -> MKPolyline {
        return routeShape
    }
    
    func getCoordinates() -> [CLLocationCoordinate2D] {
        return coords
    }
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
    private var coords: [CLLocationCoordinate2D]
    
    
    init(step: RouteStep) {
        self.startCoordinate = step.shape?.coordinates.first
        self.endCoordinate = step.shape?.coordinates.last
        self.coords = step.shape?.coordinates ?? []
        self.routeShape = NomadRoute.convertToMKPolyline(step.shape?.coordinates ?? [])
        self.direction = Direction(distance: step.distance, instructions: step.instructions, expectedTravelTime: step.expectedTravelTime)
        if step.destinations != nil || step.exitCodes != nil || step.exitNames != nil {
            self.exit = Exit(destinations: step.destinations, exitCodes: step.exitCodes, exitNames: step.exitNames)
        } else {
            self.exit = nil
        }
    }
    
    // placeholder data
    init() {
        self.startCoordinate = CLLocationCoordinate2D(latitude: 33.7501, longitude: 84.3885)
        self.endCoordinate = CLLocationCoordinate2D(latitude: 32.7501, longitude: 83.3885)
        self.routeShape = NomadRoute.convertToMKPolyline([startCoordinate!, endCoordinate!])
        self.direction = Direction(distance: 100, instructions: "Turn right in 100 miles", expectedTravelTime: TimeInterval(5000))
        self.exit = Exit(destinations: ["Atlanta", "New York"], exitCodes: ["78", "79"], exitNames: ["Georgia Ave.","Peachtree St."])
    }
    
    
    func getStartLocation() -> CLLocationCoordinate2D {
        return startCoordinate ?? CLLocationCoordinate2D()
    }
    func getEndLocation() -> CLLocationCoordinate2D {
        return endCoordinate ?? CLLocationCoordinate2D()
    }
    
    func getShape() -> MKPolyline {
        return routeShape
    }
    
    func getCoordinates() -> [CLLocationCoordinate2D] {
        return coords
    }
}
