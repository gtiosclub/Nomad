//
//  ExploreTripsView.swift
//  Nomad
//
//  Created by Lingchen Xiao on 10/3/24.
//

import SwiftUI

struct ExploreTripsView: View {
    @ObservedObject var mapManager: MapManager
    @ObservedObject var vm: UserViewModel
    @State private var currentCity: String? = nil
    var trips: [Trip]
    var previousTrips: [Trip]
    var communityTrips: [Trip]
    
    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .padding()
                                .padding(.trailing, 0)
                            if let city = vm.currentCity {
                                Text("\(city)")
                                    .font(.headline)
                            } else {
                                Text("Retrieving Location")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .task {
                            await vm.getCurrentCity()
                        }
                        
                        HStack {
                            Text("Plan your next trip, \(vm.user?.getName().split(separator: " ").first ?? "User")!")
                                .bold()
                                .font(.system(size: 20))
                                .padding(.horizontal)
                            
                            Spacer()
                            
                            // Profile picture
                            ZStack {
                                Ellipse()
                                    .fill(Color.gray)
                                    .frame(width: 40, height: 40)
                                Text((vm.user?.getName() ?? "User").prefix(1))
                                    .foregroundColor(.white)
                                    .font(.system(size: 25))
                            }
                            .padding(.trailing)
                        }
                        
                        // Itineraries
                        VStack(alignment: .leading) {
                            SectionHeaderView(title: "My itineraries")
                                .padding(.horizontal)
                            
                            
                            HStack {
                                ForEach(trips.prefix(2)) { trip in
                                    TripGridView(tripName: trip.getName(), imageURL: trip.getCoverImageURL())
                                        .frame(alignment: .top)
                                }
                            }
                            
                            SectionHeaderView(title: "Previous Itineraries")
                                .padding(.top, 5)
                                .padding(.horizontal)
                            
                            HStack {
                                ForEach(previousTrips.prefix(2)) { trip in
                                    TripGridView(tripName: trip.getName(), imageURL: trip.getCoverImageURL())
                                        .frame(alignment: .top)
                                }
                            }
                            
                            SectionHeaderView(title: "Community Favourites")
                                .padding(.top, 5)
                                .padding(.horizontal)
                            
                            HStack {
                                ForEach(communityTrips.prefix(2)) { trip in
                                    TripGridView(tripName:trip.getName(), imageURL: trip.getCoverImageURL())
                                        .frame(alignment: .top)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    struct SectionHeaderView: View {
        var title: String
        var body: some View {
            HStack {
                Text(title)
                    .font(.headline)
                    .bold()
                Spacer()
                Button(action: {}) {
                    Text("View all")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 5)
        }
    }
    
    struct TripGridView: View {
        var tripName: String
        var imageURL: String
        
        var body: some View {
            VStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .cornerRadius(10)
                    .padding(.horizontal)
                
                Text(tripName)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 5)
        }
    }
}
    
    #Preview {
        let trips = [
            Trip(start_location: Activity(address: "123 Start St", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "456 End Ave", name: "End Hotel", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), name: "Cross Country"),
            Trip(start_location: Activity(address: "789 Another St", name: "Johnson Family Spring Retreat", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "123 Another Ave", name: "Another Hotel", latitude: 34.0522, longitude: -118.2437, city: "Blue Ridge"), name: "GA Mountains")
        ]
        
        let previousTrips = [
            Trip(start_location: Activity(address: "111 Old Rd", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "222 Old Ave", name: "Previous Hotel 1", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), name: "Cool Restaurants"),
            Trip(start_location: Restaurant(address: "333 Old Rd", name: "Lorum Ipsum Pebble Beach, CA", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "444 Old Ave", name: "Previous Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "Orlando"), name: "ATL to Orlando")
        ]
        
        let communityTrips = [
            Trip(start_location: Activity(address: "555 Favorite Rd", name: "Home", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "666 Favorite Ave", name: "Favorite Hotel 1", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), name: "Scenic California Mountain Route"),
            Trip(start_location: Restaurant(address: "777 Favorite Rd", name: "Lorum ipsum Pebble Beach", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "888 Favorite Ave", name: "Favorite Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), name: "LA to SF")
        ]
        
        ExploreTripsView(mapManager: .init(), vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")), trips: trips, previousTrips: previousTrips, communityTrips: communityTrips)
    }

