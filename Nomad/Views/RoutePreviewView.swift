//
//  RoutePreviewView.swift
//  Nomad
//
//  Created by Austin Huguenard on 10/4/24.
//

import MapKit
import SwiftUI
@available(iOS 17.0, *)

struct RoutePreviewView: View {
    @StateObject var manager = RoutePreviewManager()
    @State private var mapType: MKMapType = .standard
    var trip: Trip
    @State var region: MKCoordinateRegion = MKCoordinateRegion()
    
    init(trip: Trip) {
        self.trip = trip
    }
    
    var body: some View {
        VStack {
            ZStack {
                Map(initialPosition: .automatic) {
                    Marker("Start", coordinate: self.$manager.source.wrappedValue ?? CLLocationCoordinate2D())
                    Marker("End", coordinate: self.$manager.destination.wrappedValue ?? CLLocationCoordinate2D())
                    if let route = $manager.route.wrappedValue {
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                    ForEach(self.trip.getStops(), id: \.latitude) { stop in
                        let stop_coord = CLLocationCoordinate2D(latitude: stop.getLatitude()!, longitude: stop.getLongitude()!)
                        Marker("\(stop.getName())", coordinate: stop_coord)
                    }
                }
                .onChange(of: trip, initial: true) { oldTrip, newTrip in
                    print("change to trip, updating map")
                    let start_coord = CLLocationCoordinate2D(latitude: trip.getStartLocation().getLatitude()!, longitude: trip.getStartLocation().getLongitude()!)
                    let end_coord = CLLocationCoordinate2D(latitude: trip.getEndLocation().getLatitude()!, longitude: trip.getEndLocation().getLongitude()!)
                    
                    var stop_coords: [CLLocationCoordinate2D] = []
                    for stop in trip.getStops() {
                        let stop_coord = CLLocationCoordinate2D(latitude: stop.getLatitude()!, longitude: stop.getLongitude()!)
                        stop_coords.append(stop_coord)
                    }
                    manager.setSource(coord: start_coord)
                    manager.setDestination(coord: end_coord)
                    manager.setStops(coords: stop_coords)
                    manager.calculateDirections()
                    
                    manager.region = calculateRegion(for: [start_coord, end_coord])
                    self.region = manager.region
                }
//                .onAppear() {
//                    
//                }
            }
        }
    }
    
    
    func calculateRegion(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        let minLatitude = coordinates.map { $0.latitude }.min() ?? 0.0
        let maxLatitude = coordinates.map { $0.latitude }.max() ?? 0.0
        let minLongitude = coordinates.map { $0.longitude }.min() ?? 0.0
        let maxLongitude = coordinates.map { $0.longitude }.max() ?? 0.0
        
        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLatitude - minLatitude) * 1.5,
            longitudeDelta: (maxLongitude - minLongitude) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
    }
}

#Preview {
    RoutePreviewView(trip: Trip(start_location: Restaurant(address: "848 Spring Street Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "1000 Peachtree Street Atlanta GA 30308", name: "The Ritz-Carlton", latitude: -84.383168, longitude: 33.781489), start_date: "10-05-2024", end_date: "10-05-2024"))
}
