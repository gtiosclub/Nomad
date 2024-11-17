//
//  RoutePreviewAtlasView.swift
//  Nomad
//
//  Created by Austin Huguenard on 10/4/24.
//

import MapKit
import SwiftUI
@available(iOS 17.0, *)

struct RoutePreviewAtlasView: View {
    @ObservedObject var vm: UserViewModel
    @ObservedObject var cvm: ChatViewModel
    @Binding var trip: Trip
    @State var position: MapCameraPosition = .automatic
    @Binding var currentStopLocation: CLLocationCoordinate2D?
    var showStopMarker: Bool = false
    
    
    
    var body: some View {
        VStack {
            Map(position: $position) {
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
                
                ForEach(cvm.pois, id: \.self) { stop in
                    let stop_coord = CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
                    Marker("\(stop.name)", coordinate: stop_coord).tint(.green)
                }

                
                
            }
            .onChange(of: cvm.pois) { newPois in
                var poi_coords = cvm.pois.map { CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }
                
                if let route = trip.route {
                    if poi_coords.isEmpty {
                        poi_coords.append(route.getEndLocation())
                        poi_coords.append(contentsOf: trip.getStops().map { CLLocationCoordinate2D(latitude: $0.getLatitude(), longitude: $0.getLongitude()) })
                    }
                    poi_coords.append(route.getStartLocation())
                }
                
                let region = calculateRegion(for: poi_coords)
                withAnimation {
                    self.position = .region(region)
                }
            }
            .onChange(of: trip, initial: true) { oldTrip, newTrip in
                let start_coord = self.trip.getRoute()?.getStartLocation() ?? CLLocationCoordinate2D()
                let end_coord = self.trip.getRoute()?.getEndLocation() ?? CLLocationCoordinate2D()
                
                let region = calculateRegion(for: [start_coord, end_coord])
                withAnimation {
                    self.position = .region(region)
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

//#Preview {
//    RoutePreviewAtlasView(mapManager: MapManager(), trip: Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "1000 Peachtree Street, Atlanta GA 30308", name: "The Ritz-Carlton", latitude: -84.383168, longitude: 33.781489), start_date: "10-05-2024", end_date: "10-05-2024"))
//}
