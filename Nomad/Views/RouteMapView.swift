//
//  RouteMapView.swift
//  Nomad
//
//  Created by Austin Huguenard on 10/4/24.
//

import MapKit
import SwiftUI
@available(iOS 17.0, *)

struct RouteMapView: View {
    @ObservedObject var vm: UserViewModel
    @Binding var trip: Trip
    @State var region: MKCoordinateRegion = MKCoordinateRegion()
    @Binding var currentStopLocation: CLLocationCoordinate2D?
    var showStopMarker: Bool = false
    
    var body: some View {
        VStack {
            Map(initialPosition: .automatic) {
                if let route = trip.route {
                    Marker("Start", coordinate: route.getStartLocation())
                    Marker("End", coordinate: route.getEndLocation())
                    if (showStopMarker) {
                        Marker("Stop Search Location", coordinate: $currentStopLocation.wrappedValue!).tint(.red)
                    }
                    MapPolyline(route.getShape())
                        .stroke(.blue, lineWidth: 5)
                }
                ForEach(trip.getStops(), id: \.latitude) { stop in
                    let stop_coord = CLLocationCoordinate2D(latitude: stop.getLatitude(), longitude: stop.getLongitude())
                    Marker("\(stop.getName())", coordinate: stop_coord)
                }
                ForEach(vm.stops(for: vm.currentSelection), id: \.latitude) { stop in
                    let stop_coord = CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
                    Marker("\(stop.name)", coordinate: stop_coord).tint(.green)
                }
            }
            .onChange(of: trip, initial: true) { oldTrip, newTrip in
                let start_coord = self.trip.getRoute()?.getStartLocation() ?? CLLocationCoordinate2D()
                let end_coord = self.trip.getRoute()?.getEndLocation() ?? CLLocationCoordinate2D()
                
                self.region = calculateRegion(for: [start_coord, end_coord])
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

//#Preview {
//    RouteMapView(mapManager: MapManager(), trip: Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "1000 Peachtree Street, Atlanta GA 30308", name: "The Ritz-Carlton", latitude: -84.383168, longitude: 33.781489), start_date: "10-05-2024", end_date: "10-05-2024"))
//}
