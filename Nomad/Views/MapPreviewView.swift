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
    private var route: NomadRoute
    @State private var mapType: MKMapType = .standard
    @State private var stopMarkers : [CLLocationCoordinate2D]
    private var region: MKCoordinateRegion = MKCoordinateRegion()
    var polylines: [MKPolyline]
    init(route: NomadRoute, stopMarkers: [CLLocationCoordinate2D]?) {
        self.route = route
        self.stopMarkers = stopMarkers ?? []
        self.polylines = route.getRoutePolyline()
        self.region = self.calculateRegion()
    }
    
    var body: some View {
        VStack{
            ZStack {
                Map(initialPosition: MapCameraPosition.region(region)) {
                    Marker("Start", coordinate: getStartCoord())
                    Marker("End", coordinate: getEndCoord())
                    
                    ForEach(stopMarkers, id: \.latitude) { stop in
                        Marker("Stop", coordinate: stop)
                    }
                    
                    ForEach(polylines, id: \.self) { polyline in
                        MapPolyline(polyline)
                    }
                }
            }
        }
    }
    func getStartCoord() -> CLLocationCoordinate2D {
        return  route.steps[0].startCoordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    }
    func getEndCoord() -> CLLocationCoordinate2D {
        return  route.steps[0].startCoordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    }
    func calculateRegion() -> MKCoordinateRegion {
        let coordinates = [getStartCoord(), getEndCoord()]
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
