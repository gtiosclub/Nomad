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
    @ObservedObject var vm: UserViewModel
    @State var trip: Trip
    
    // User inputs
    @State private var tripTitle: String = ""
    @State private var isPublic: Bool = true
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Preview Your Route")
                    .font(.headline)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                    .padding(.top)
                
                RoutePreviewView(vm: vm, trip: $trip)
                    .frame(height: 300)
                
                Spacer().frame(height: 20)
                
                HStack {
                    VStack {
                        Text(formatTimeDuration(duration: trip.route?.getTotalTime() ?? TimeInterval(0)))
                            .padding()
                            .fontWeight(.bold)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .frame(maxWidth: .infinity)
                    
                    VStack {
                        Text(formatDistance(distance: trip.route?.getTotalDistance() ?? 0))
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
                    NavigationLink(destination: TripView(vm: vm)) {
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
            if let route = vm.getTrip(trip_id: trip.id)?.route {
                trip.route = route
            } else {
                Task {
                    await updateTripRoute()
                }
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
        
        if let newRoutes = await vm.mapManager.generateRoute(pois: all_pois) {
            print("setting new route")
            trip.route = newRoutes[0]
            vm.updateTrip(trip: trip)
        }
    }
    
    // duration is in seconds
    func formatTimeDuration(duration: TimeInterval) -> String {
        let minsLeft = Int(duration.truncatingRemainder(dividingBy: 3600))
        return "\(Int(duration / 3600)) hr \(Int(minsLeft / 60)) min"
    }
    func formatDistance(distance: Double) -> String {
        return String(format: "%.0f miles", distance)
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
    PreviewRouteView(vm: .init(user: User(id: "sampleUserID", name: "Sample User", trips: [
        Trip(start_location: Restaurant(address: "848 Spring Street Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090),
             end_location: Hotel(address: "201 8th Ave S Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947),
             start_date: "10-05-2024", end_date: "10-05-2024", stops: [])
    ])), trip: Trip(start_location: Restaurant(address: "848 Spring Street Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090),
                    end_location: Hotel(address: "201 8th Ave S Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947),
                    start_date: "10-05-2024", end_date: "10-05-2024", stops: []))
}
