//
//  ExploreTripsView.swift
//  Nomad
//
//  Created by Lingchen Xiao on 10/3/24.
//

import SwiftUI

struct ExploreTripsView: View {
    let user = User(id: "1", name: "John Howard")
    @ObservedObject var userViewModel: UserViewModel
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
                            if let city = currentCity {
                                Text("Current Location: \(city)")
                                    .font(.headline)
                                    .padding()
                            } else {
                                Text("Getting Current Location...")
                                    .font(.headline)
                                    .padding()
                            }
                            Image(systemName: "mappin.and.ellipse")
                            Spacer()
                        }
                        
                        
                        HStack {
                            Text("Plan your next trip, John!")
                                .bold()
                                .font(.system(size: 20))
                                .padding(.horizontal)
                                .padding(.top, 10)
                            Spacer()
                            
                            // Profile picture
                            ZStack {
                                Ellipse()
                                    .fill(Color.gray)
                                    .frame(width: 50, height: 50)
                                Text(user.getName().prefix(1))
                                    .foregroundColor(.white)
                                    .font(.system(size: 30, weight: .bold))
                            }
                            .padding(.trailing)
                        }
                        
                        // Itineraries
                        VStack(alignment: .leading) {
                            SectionHeaderView(title: "My itineraries")
                                .padding()
                            
                            
                            HStack {
                                ForEach(trips.prefix(2)) { trip in
                                    TripGridView(tripName: trip.getStartLocation().name)
                                }
                            }
                            
                            SectionHeaderView(title: "Previous Itineraries")
                                .padding()
                            
                            HStack {
                                ForEach(previousTrips.prefix(2)) { trip in
                                    TripGridView(tripName: trip.getStartLocation().name)
                                }
                            }
                            
                            SectionHeaderView(title: "Community Favourites")
                                .padding()
                            
                            HStack {
                                ForEach(communityTrips.prefix(2)) { trip in
                                    TripGridView(tripName:trip.getStartLocation().name )
                                }
                            }
                        }
                        
                    }
                }
              
                VStack {
                    Spacer()
                    HStack {
                        VStack {
                            Image(systemName: "map.fill")
                            Text("Navigate")
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "pencil")
                            Text("Plan")
                        }
                        Spacer()
                        VStack {
                            Image(systemName: "play.square")
                            Text("Recap")
                        }
                    }
                    .padding()
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
    
        
        var body: some View {
            VStack {
                // Images, for now placed with rectangles
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 120, height: 120)
                    .cornerRadius(10)
                Text(tripName)
                    .font(.headline)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding()
                
                Spacer()
            }
            .padding(.vertical, 5)
        }
    }
}
    
    #Preview {
        let trips = [
            Trip(start_location: Activity(address: "123 Start St", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "456 End Ave", name: "End Hotel", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles")),
            Trip(start_location: Activity(address: "789 Another St", name: "Johnson Family Spring Retreat", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "123 Another Ave", name: "Another Hotel", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"))
        ]
        let previousTrips = [
            Trip(start_location: Activity(address: "111 Old Rd", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "222 Old Ave", name: "Previous Hotel 1", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles")),
            Trip(start_location: Restaurant(address: "333 Old Rd", name: "Lorum Ipsum Pebble Beach, CA", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "444 Old Ave", name: "Previous Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"))
        ]
        
        let communityTrips = [
            Trip(start_location: Activity(address: "555 Favorite Rd", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "666 Favorite Ave", name: "Favorite Hotel 1", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles")),
            Trip(start_location: Restaurant(address: "777 Favorite Rd", name: "Lorum ipsum Pebble Beach", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "888 Favorite Ave", name: "Favorite Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"))
        ]
        
        ExploreTripsView(userViewModel: UserViewModel(), trips: trips, previousTrips: previousTrips, communityTrips: communityTrips)
    }

