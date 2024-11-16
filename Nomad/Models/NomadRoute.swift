//
//  Step.swift
//  Nomad
//
//  Created by Vignesh Suresh Kumar on 10/1/24.
//

import MapKit
import MapboxDirections

struct NomadRoute {
    var id = UUID()
    var route: Route? // mapbox object, not sure if we need anything from here yet.
    var legs: [NomadLeg]
    
    func getStartLocation() -> CLLocationCoordinate2D {
        return legs.first?.startCoordinate ?? CLLocationCoordinate2D()
    }
    
    func getEndLocation() -> CLLocationCoordinate2D {
        return legs.last?.endCoordinate ?? CLLocationCoordinate2D()
    }
    
    func totalDistance() -> CLLocationDistance {
        return legs.reduce(0) { $0 + $1.totalDistance() } * 0.000621371
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
    
    func getJsonCoordinatesMap() -> [String : String] {
        var legCoordsMap: [String : String] = [:]
        
        for (i, leg) in legs.enumerated() {
            let coords = leg.getJSONCoordinates()
            let coordsStr = coords.map { coord in "\(coord.latitude),\(coord.longitude)" }.joined(separator: ";")
            legCoordsMap[String(i)] = coordsStr
        }
        
        return legCoordsMap
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
    var id: UUID = UUID()
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
    
    private func legToSteps(leg: MapboxDirections.RouteLeg) -> [NomadStep] {
        var steps = [NomadStep]()
        for step in leg.steps {
            steps.append(NomadStep(step: step))
        }
        return steps
    }
    
    private mutating func initWithSteps(steps: [NomadStep]) {
        self.steps = steps
        self.startCoordinate = steps.first?.startCoordinate ?? CLLocationCoordinate2D()
        self.endCoordinate = steps.last?.endCoordinate ?? CLLocationCoordinate2D()
    }
    
    public func getJSONCoordinates() -> [CLLocationCoordinate2D] {
        let origCoords = getCoordinates()
        if origCoords.count < 2 {
            return origCoords
        }
        
        let MAX_COORDS: Double = 100
        var jsonCoords = [CLLocationCoordinate2D]()
        let stepSize = Int(ceil(Double(origCoords.count + 1) / MAX_COORDS))
        for i in stride(from: 0, to:origCoords.count - 1, by: stepSize) {
            jsonCoords.append(origCoords[i])
        }
        if (jsonCoords.last! != origCoords[origCoords.count - 1]) {
            if (jsonCoords.count < Int(MAX_COORDS)) {
                jsonCoords.append(origCoords[origCoords.count - 1])
            } else {
                jsonCoords[jsonCoords.count - 1] = origCoords[origCoords.count - 1]
            }
        }
        
        return jsonCoords
    }
    
    
    private func getCoordinateString(coord: CLLocationCoordinate2D) -> String {
        return "\(coord.latitude),\(coord.longitude)"
    }
    
    private func parseCoordinateString(coordString: String) -> CLLocationCoordinate2D {
        let coords = coordString.split(separator: ",")
        return CLLocationCoordinate2D(latitude: Double(coords[0]) ?? 0.0, longitude: Double(coords[1]) ?? 0.0)
    }
    
}

struct NomadStep: Equatable {
    let id = UUID()
    
    static func ==(lhs: NomadStep, rhs: NomadStep) -> Bool {
        return lhs.id == rhs.id
    }
    
    struct Direction {
        var distance: CLLocationDistance
        var instructions: String
        var expectedTravelTime: TimeInterval
        var exitCodes: [String]?
        var exitIndex: Int?
        let instructionsDisplayedAlongStep: [VisualInstructionBanner]?
        let maneuverDirection: ManeuverDirection?
        let maneuverType: ManeuverType
        let intersections: [Intersection]?
        let names: [String]? //The names of the road or path leading from this step’s maneuver to the next step’s maneuver.
        
        init(distance: CLLocationDistance, instructions: String, expectedTravelTime: TimeInterval, exitCodes: [String]?, exitIndex: Int?, instructionsDisplayedAlongStep: [VisualInstructionBanner]?, maneuverDirection: ManeuverDirection?, maneuverType: ManeuverType, intersections: [Intersection]?, names: [String]?) {
            self.distance = distance
            self.instructions = instructions
            self.expectedTravelTime = expectedTravelTime
            self.exitCodes = exitCodes
            self.exitIndex = exitIndex
            self.instructionsDisplayedAlongStep = instructionsDisplayedAlongStep
            self.maneuverDirection = maneuverDirection
            self.maneuverType = maneuverType
            self.intersections = intersections
            self.names = names
            
            // print(self.toString())
            
        } //The names of the road or path leading from this step’s maneuver to the next step’s maneuver.
        
        init(step: RouteStep) {
            self.init(distance: step.distance, instructions: step.instructions, expectedTravelTime: step.expectedTravelTime, exitCodes: step.exitCodes, exitIndex: step.exitIndex, instructionsDisplayedAlongStep: step.instructionsDisplayedAlongStep, maneuverDirection: step.maneuverDirection, maneuverType: step.maneuverType, intersections: step.intersections, names: step.names)
        }
        init() {
            self.init(distance: 500, instructions: "Turn right in 0.4 miles", expectedTravelTime: TimeInterval(50), exitCodes: nil, exitIndex: nil, instructionsDisplayedAlongStep: nil, maneuverDirection: nil, maneuverType: .turn, intersections: nil, names: nil)
        }
        
        
        func toString() -> String {
            return """
            Distance: \(distance) m
            Instructions: \(instructions)
            Expected Travel Time: \(expectedTravelTime / 60) mins
            Exit Codes: \(exitCodes ?? [])
            Exit Index: \(exitIndex ?? -1)
            Maneuver Type: \(maneuverType.rawValue)
            Maneuver Direction: \(maneuverDirection?.rawValue ?? "NONE")
            // Number Instructions Displayed Along Step: \(instructionsDisplayedAlongStep)
            Names: \(names ?? [])
            """
            // Intersections: \(intersections ?? [])

        }
        
        func printInstructions() -> String? {
            return instructionsDisplayedAlongStep?.description
        }
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
        self.direction = Direction(step: step)
        if step.destinations != nil || step.exitCodes != nil || step.exitNames != nil {
            self.exit = Exit(destinations: step.destinations, exitCodes: step.exitCodes, exitNames: step.exitNames)
        } else {
            self.exit = nil
        }
    }
    
    // placeholder data
    init(direction: Direction) {
        self.startCoordinate = CLLocationCoordinate2D(latitude: 33.7501, longitude: 84.3885)
        self.endCoordinate = CLLocationCoordinate2D(latitude: 32.7501, longitude: 83.3885)
        self.coords = []
        self.routeShape = NomadRoute.convertToMKPolyline([startCoordinate, endCoordinate])
        self.direction = direction
        self.exit = Exit(destinations: ["Atlanta", "New York"], exitCodes: ["78", "79"], exitNames: ["Georgia Ave.","Peachtree St."])
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
