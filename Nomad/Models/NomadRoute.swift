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
    var route: Route? // mapbox object, not sure if we need anything from here yet.
    var legs: [NomadLeg]
    
    
    func getStartLocation() -> CLLocationCoordinate2D {
        return legs.first?.startCoordinate ?? CLLocationCoordinate2D()
    }
    
    func getEndLocation() -> CLLocationCoordinate2D {
        return legs.last?.endCoordinate ?? CLLocationCoordinate2D()
    }
    
    func totalDistance() -> CLLocationDistance {
        return legs.reduce(0) { $0 + $1.totalDistance() }
    }
    
    func totalTime() -> TimeInterval {
        return legs.reduce(0) { $0 + $1.totalTime() }
    }
    
    // returns an array of polylines for each step of the route.
    func getShape() -> MKPolyline {
        let coords = getCoordinates()
        return NomadRoute.convertToMKPolyline(coords)
    }
    
    func getCoordinates() -> [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D]()
        for leg in legs {
            coords.append(contentsOf: leg.getCoordinates())
        }
        return coords
    }
    
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
    var steps: [NomadStep]
    var startCoordinate: CLLocationCoordinate2D
    var endCoordinate: CLLocationCoordinate2D
    
    init(leg: MapboxDirections.RouteLeg) {
        var steps = [NomadStep]()
        for step in leg.steps {
            steps.append(NomadStep(step: step))
        }
        self.init(steps: steps)
    }
    
    init(steps: [NomadStep]) {
        self.steps = steps
        self.startCoordinate = steps.first?.startCoordinate ?? CLLocationCoordinate2D()
        self.endCoordinate = steps.last?.endCoordinate ?? CLLocationCoordinate2D()
        
    }
    func totalDistance() -> CLLocationDistance {
        return steps.reduce(0) { $0 + $1.direction.distance }
    }
    
    func totalTime() -> TimeInterval {
        return steps.reduce(0) { $0 + $1.direction.expectedTravelTime }
    }
    
    func getStartLocation() -> CLLocationCoordinate2D {
        return startCoordinate
    }
    func getEndLocation() -> CLLocationCoordinate2D {
        return endCoordinate
    }
    
    func getShape() -> MKPolyline {
        let coords = getCoordinates()
        return NomadRoute.convertToMKPolyline(coords)
    }
    
    func getCoordinates() -> [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D]()
        for step in steps {
            coords.append(contentsOf: step.getCoordinates())
        }
        return coords
    }
}

struct NomadStep {
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
    
    private var routeShape: MKPolyline
    var startCoordinate: CLLocationCoordinate2D
    var endCoordinate: CLLocationCoordinate2D
    var direction: Direction
    var exit: Exit?
    private var coords: [CLLocationCoordinate2D]
    
    
    init(step: RouteStep) {
        self.startCoordinate = step.shape?.coordinates.first ?? CLLocationCoordinate2D()
        self.endCoordinate = step.shape?.coordinates.last ?? CLLocationCoordinate2D()
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
        self.coords = []
        self.routeShape = NomadRoute.convertToMKPolyline([startCoordinate, endCoordinate])
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
