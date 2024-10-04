//
//  MapView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//
import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct MapView: View {
    @ObservedObject var mapManager = MapManager()
    @State var selectedAddress = ""
    
    private let startingPoint = CLLocationCoordinate2D(
        latitude: 40.83657722488077,
        longitude: 14.306896671048852
    )
    
    private let destinationCoordinates = CLLocationCoordinate2D(
        latitude: 40.849761,
        longitude: 14.263364
    )
    var body: some View {
        ZStack {
            // All views within Map
            Map(interactionModes: MapInteractionModes.all, position: $mapManager.mapPosition) {
                // Adding markers for the start and finish points
                Marker("Start", coordinate: mapManager.source.coordinate)
                Marker("Finish", coordinate: mapManager.destination.coordinate)
                if let userLocation = mapManager.userLocation {
                    Marker("Your Location", coordinate: userLocation)
                }
              
              if let startCoordinate = mapManager.startCoordinate {
                Marker("Start", coordinate: startCoordinate)
            }
              if let endCoordinate = mapManager.endCoordinate {
                Marker("End", coordinate: endCoordinate)

            }

            
              // Show the route if it is available
              if let legPolylines = mapManager.legPolylines {
                ForEach(legPolylines, id:\.self) { polyline in
                    MapPolyline(polyline)
                        .stroke(.blue, lineWidth: 5)
                }
            }

            
        }.task {
            do {
                await mapManager.setupMapbox()
                try await mapManager.addWaypoint(to: startingPoint)
                try await mapManager.addWaypoint(to: destinationCoordinates)
                mapManager.getDirections()
            } catch {
                print("ERrors \(error)")
            }
                
                // Display the route if it exists
                if let route = mapManager.route {
                    MapPolyline(route)
                        .stroke(.blue, lineWidth: 5)
                }
            }.mapStyle(getMapStyle())
                .onAppear() {
                    mapManager.setSource(coord: startingPoint)
                    mapManager.setDestination(coord: destinationCoordinates)
                    mapManager.getDirections()
                }
            // All Map HUD
            VStack {
                HStack {
                    Spacer()
                    VStack {
                        CompassView(bearing: $mapManager.bearing)
                            .frame(width: 50, height: 50)
                        RecenterMapView(recenterMap: {
                            if let userLocation = mapManager.userLocation {
                                mapManager.mapPosition = .camera(MapCamera(centerCoordinate: userLocation, distance: 5000, heading: 0, pitch: 0))
                            }
                        })
                        .frame(width: 50, height: 50)
                        ChangeMapTypeButtonView(selectedMapType: $mapManager.mapType)
                            .frame(width: 50, height: 50)
                    }
                }
                Spacer()
                LocationSearchBox(selectedAddress: $selectedAddress)
                    .padding()
            }
        }
    }
    func getMapStyle() -> MapStyle {
        switch mapManager.mapType {
        case .defaultMap:
            return .standard
        case .satellite:
            return .imagery
        case .terrain:
            return .hybrid
        }
    }
}


#Preview {
    MapView()
}
