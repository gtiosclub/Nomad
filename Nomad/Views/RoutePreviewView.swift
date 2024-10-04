//
//  RoutePreviewView.swift
//  Nomad
//
//  Created by Austin Huguenard on 10/4/24.
//

import MapKit
import SwiftUI
@available(iOS 17.0, *)

struct RoutePrevieView: View {
    @ObservedObject var manager = MapManager()
    @State private var mapType: MKMapType = .standard
    @State private var selectedResult: MKMapItem?
    @ObservedObject var vm: UserViewModel
    
    @State var region: MKCoordinateRegion = MKCoordinateRegion()
    
    init(vm: UserViewModel) {
        self.vm = vm
        var start_coord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        var end_coord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        if let trip = vm.current_trip {
            start_coord = CLLocationCoordinate2D(latitude: trip.getStartLocation().getLatitude() ?? 0, longitude: trip.getStartLocation().getLongitude() ?? 0)
            end_coord = CLLocationCoordinate2D(latitude: trip.getEndLocation().getLatitude() ?? 0, longitude: trip.getEndLocation().getLongitude() ?? 0)
        }
        
        self.region = calculateRegion(for: [start_coord, end_coord])
    }
    
    var body: some View {
        VStack{
            ZStack {
                Map(selection: $selectedResult) {
                    Marker("Start", coordinate: self.manager.source.coordinate)
                    Marker("End", coordinate: self.manager.destination.coordinate)
                    if let route = manager.route {
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                    ForEach(self.vm.current_trip?.getStops() ?? [], id: \.latitude) { stop in
                        var stop_coord = CLLocationCoordinate2D(latitude: stop.getLatitude()!, longitude: stop.getLongitude()!)
                        Marker("Stop", coordinate: stop_coord)
                    }
                }
                .onChange(of: vm.current_trip!) { newTrip in
                    var start_coord = CLLocationCoordinate2D(latitude: newTrip.getStartLocation().getLatitude()!, longitude: newTrip.getStartLocation().getLongitude()!)
                    var end_coord = CLLocationCoordinate2D(latitude: newTrip.getEndLocation().getLatitude()!, longitude: newTrip.getEndLocation().getLongitude()!)
                    
                    var stop_coords: [CLLocationCoordinate2D] = []
                    for stop in newTrip.getStops() {
                        var stop_coord = CLLocationCoordinate2D(latitude: stop.getLatitude()!, longitude: stop.getLongitude()!)
                        stop_coords.append(stop_coord)
                    }
                    
                    manager.getDirections(from: start_coord, to: end_coord, via: stop_coords)
                }
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
    RoutePrevieView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard", trips: [Trip(start_location: Restaurant(address: "848 Spring Street Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "1000 Peachtree Street Atlanta GA 30308", name: "The Ritz-Carlton", latitude: -84.383168, longitude: 33.781489), start_date: "10-05-2024", end_date: "10-05-2024")])))
}
