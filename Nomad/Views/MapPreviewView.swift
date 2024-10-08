//
//  MapPreviewView.swift
//  Nomad
//
//  Created by Karen Lu on 9/17/24.
//
import MapKit
import SwiftUI
@available(iOS 17.0, *)
struct MapPreviewView: View {
    @ObservedObject var manager = MapManager()
    @State private var mapType: MKMapType = .standard
    @State private var selectedResult: MKMapItem?
    
    let startingCoordinates : CLLocationCoordinate2D
    let endCoordinates : CLLocationCoordinate2D
    @State private var stopMarkers : [CLLocationCoordinate2D]
    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 33.7488, longitude: -84.3877), span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5))
    
    init(startingCoordinates: CLLocationCoordinate2D, endCoordinates: CLLocationCoordinate2D, stopMarkers: [CLLocationCoordinate2D] = []) {
        self.startingCoordinates = startingCoordinates
        self.endCoordinates = endCoordinates
        self.stopMarkers = stopMarkers
        self.region = calculateRegion(for: [startingCoordinates, endCoordinates])
    }
    
    var body: some View {
        VStack{
            ZStack {
                Map(selection: $selectedResult) {
                    Marker("Start", coordinate: self.startingCoordinates)
                    Marker("End", coordinate: self.endCoordinates)
                    if let route = manager.route {
                        MapPolyline(route)
                            .stroke(.blue, lineWidth: 5)
                    }
                    ForEach(stopMarkers, id: \.latitude) { stop in
                        Marker("Stop", coordinate: stop)
                    }
                }
            }
            Button(action: {
                manager.setSource(coord: startingCoordinates)
                manager.setDestination(coord: endCoordinates)
                manager.getDirections()
            }) {
                Text("Get Directions")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
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
    MapPreviewView(
        startingCoordinates: CLLocationCoordinate2D(latitude: 33.7488, longitude: -84.3877),
        endCoordinates: CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298),
        stopMarkers: [CLLocationCoordinate2D(latitude: 36.8781, longitude: -87.6298)])
}
