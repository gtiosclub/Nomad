//
//  PreviewRouteView.swift
//  Nomad
//
//  Created by amber verma on 10/8/24.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct PreviewRouteView: View {
    @ObservedObject var mapManager: MapManager
    @ObservedObject var vm: UserViewModel
    @State private var tripTitle: String = ""
    @State private var isPublic: Bool = true
    @State var trip: Trip
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Preview Your Route")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .padding(.top)
                
                RoutePreviewView(mapManager: mapManager, trip: $trip)
                    .frame(height: 300)
                
                Spacer().frame(height: 20)
                
                HStack {
                    VStack {
                        Text("\(Int(vm.total_time / 60)) hr \(Int(vm.total_time.truncatingRemainder(dividingBy: 60))) min")
                            .padding()
                            .fontWeight(.bold)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text("\(vm.total_distance, specifier: "%.0f") miles")
                            .padding()
                            .fontWeight(.bold)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)
                
                Text("Route Details")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                
                if let trip = vm.current_trip {
                    RoutePlanListView(vm: vm)
                        .frame(height: 200)
                        .padding()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .overlay(Text("No Route Details Available").foregroundColor(.gray))
                        .padding()
                }
                
                Text("Finalize Your Route")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Route Name")
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 10)
                
                TextField("Trip Title", text: $tripTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                VStack {
                    Text("Route Visibility")
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                    
                    VStack {
                        RadioButton(text: "Public", isSelected: $isPublic, value: true)
                        RadioButton(text: "Private", isSelected: $isPublic, value: false)
                    }
                }
                
                HStack {
                    NavigationLink(destination: TripView(mapManager: mapManager, vm: vm)) {
                        Button("Edit Route") {
                            
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                    }
                    
                    Spacer(minLength: 10)
                    
                    Button("Save Route") {
                        
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
            }
        }
        .onAppear {
            vm.setCurrentTrip(trip: trip)
            Task {
                await updateTripRoute()
            }
        }
    }
    func updateTripRoute() async {
        let start_loc = trip.getStartLocation()
        let end_loc = trip.getEndLocation()
        let all_stops = trip.getStops()
        
        var all_pois: [any POI] = []
        all_pois.append(start_loc)
        all_pois.append(contentsOf: all_stops)
        all_pois.append(end_loc)
        
        if let newRoutes = await mapManager.generateRoute(pois: all_pois) {
            
            trip.setRoute(route: newRoutes[0])
        }
    }
    
    struct RadioButton: View {
        var text: String
        @Binding var isSelected: Bool
        var value: Bool
        
        var body: some View {
            Button(action: {
                isSelected = value
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .stroke(Color.gray, lineWidth: 2)
                            .frame(width: 10, height: 10)
                        
                        if isSelected == value {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 12, height: 12)
                        }
                    }
                    Text(text)
                        .foregroundColor(.black)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    PreviewRouteView(mapManager: .init(), vm: .init(user: User(id: "sampleUserID", name: "Sample User", trips: [
        Trip(start_location: Restaurant(address: "848 Spring Street Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090),
             end_location: Hotel(address: "201 8th Ave S Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947),
             start_date: "10-05-2024", end_date: "10-05-2024", stops: [])
    ])), trip: Trip(start_location: Restaurant(address: "848 Spring Street Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090),
                    end_location: Hotel(address: "201 8th Ave S Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947),
                    start_date: "10-05-2024", end_date: "10-05-2024", stops: []))
}
