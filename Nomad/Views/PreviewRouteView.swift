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
    @State private var title: String = ""
    @State private var isPrivate: Bool = true
    @Environment(\.dismiss) var dismiss
    
    var trip: Trip
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Preview Your Route")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .padding(.top)
                    
                    if let trip = vm.current_trip {
                        RoutePreviewView(mapManager: mapManager, trip: trip)
                            .frame(height: 300)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(Text("No Trip Available").foregroundColor(.gray))
                    }
                    
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
                        .padding(.top)
                        
                    
                    if let trip = vm.current_trip {
                        RoutePlanListView(vm: vm)
                            .frame(height: 100)
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
                        .padding(.leading)
                        .padding(.top)
                    
                    Text("Route Name")
                        .font(.body)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .padding(.top)
                    
                    TextField("Trip Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Route Visibility")
                            .font(.body)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                            
                        
                        VStack(alignment: .leading) {
                            RadioButton(text: "Public", isSelected: $isPrivate, value: false)
                            RadioButton(text: "Private", isSelected: $isPrivate, value: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading, 30)
                    }
                    
                    HStack {
                        NavigationLink(destination: FindStopView(mapManager: mapManager, vm: vm)) {
                            Text("Edit Route")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(8)
                                .foregroundColor(Color.black)
                        }
                        
                        Spacer().frame(width: 60)
                        
                        Button("Save Route") {
                            vm.setTripTitle(newTitle: title)
                            vm.setTripVisibility(isPrivate: isPrivate)
                            
                            dismiss()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear {
                vm.setCurrentTrip(trip: trip)
            }
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
        Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville", coverImageURL: "https://pixabay.com/get/g396fa4b9bb9c1731092f12dcf2bb686fc52caaa5dc7a6f7a9edafe2c402bfe67b1a3affcdae0731b43338a151f0d3b21_640.jpg")
    ])), trip: Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville", coverImageURL: "https://pixabay.com/get/g396fa4b9bb9c1731092f12dcf2bb686fc52caaa5dc7a6f7a9edafe2c402bfe67b1a3affcdae0731b43338a151f0d3b21_640.jpg"))
}
