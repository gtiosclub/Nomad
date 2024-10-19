//
//  Step.swift
//  Nomad
//
//  Created by Vignesh Suresh Kumar on 10/1/24.
//

import MapKit
import MapboxDirections

struct NomadRoute: Codable {
    var id = UUID()
    var route: Route? // mapbox object, not sure if we need anything from here yet.
    var legs: [NomadLeg]
    
    enum CodingKeys: String, CodingKey {
        case id
        case startCoordinate
        case legs // TODO: Add to encoder/decoder
    }
    
    // sets route to null, use [method name here] to generate route
    init(from decoder: Decoder) throws {
        // Set route to null initially, create separate method that actually generates route from MapBox
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try values.decode(UUID.self, forKey: .id)

    }
    
    func getStartLocation() -> CLLocationCoordinate2D {
        return legs.first?.startCoordinate ?? CLLocationCoordinate2D()
    }
    
    func getEndLocation() -> CLLocationCoordinate2D {
        return legs.last?.endCoordinate ?? CLLocationCoordinate2D()
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


        
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id.uuidString, forKey: .id)
        
        try container.encode(getCoordinateString(coord: getStartLocation()), forKey: .startCoordinate)
        try container.encode(getCoordinateString(coord: getEndLocation()), forKey: .endCoordinate)
        
        
    }
}

struct NomadLeg {
    let id = UUID()
    var steps: [NomadStep]
    var startCoordinate: CLLocationCoordinate2D
    var endCoordinate: CLLocationCoordinate2D
    
    enum CodingKeys: String, CodingKey {
        case id
        case coordinates
    }
    
    init(leg: MapboxDirections.RouteLeg) {
        self.init(steps: legToSteps(leg: leg))
    }
    
    init(steps: [NomadStep]) {
        initWithSteps(steps: steps)
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        
        let coordinatesStr = try values.decode(String.self, forKey: .coordinates)
        let coordinates = coordinatesStr.split(separator: ";").map { parseCoordinateString(coordString: String($0)) }
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
    
    private func getJSONCoordinates() -> [CLLocationCoordinate2D] {
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
    
    private func coordinatesToLeg(coords: [CLLocationCoordinate2D]) async {
        let options = MatchOptions(coordinates: coords)
        options.includesSteps = true
        
        var steps = [NomadStep]()
                
        // TODO: Best determine way to get this async data
        let directions = Directions.shared
        let task = directions.calculate(options) { result in
            switch result {
            case .failure(let error):
                print("Could not generate route from coordinates: \(error)")
            case .success(let response):
                steps = parseDirectionsResult(response: response)
                // TODO: Determine how to set struct properties w/o mutation error
                
            }
        }
        task.resume()
        
    }
    
    private func parseDirectionsResult(response: MapMatchingResponse) -> [NomadStep] {
        guard let match = response.matches?.first, let leg = match.legs.first else {
            return []
        }
        return legToSteps(leg: leg)
    }
    
    private func getCoordinateString(coord: CLLocationCoordinate2D) -> String {
        return "\(coord.latitude),\(coord.longitude)"
    }
    
    private func parseCoordinateString(coordString: String) -> CLLocationCoordinate2D {
        let coords = coordString.split(separator: ",")
        return CLLocationCoordinate2D(latitude: Double(coords[0]) ?? 0.0, longitude: Double(coords[1]) ?? 0.0)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.id.uuidString, forKey: .id)
        
        let jsonCoordStrings = self.getJSONCoordinates().map { getCoordinateString(coord: $0) }
        try container.encode(jsonCoordStrings.joined(separator: ";"), forKey: .coordinates)
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
