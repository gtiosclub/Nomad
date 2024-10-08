//
//  RootView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct RootView: View {
    @State var selectedTab = 2
    @ObservedObject var mapManager = MapManager()
    @State private var mapboxSetUp: Bool = false
  
    var community_trips = [
        Trip(start_location: Activity(address: "555 Favorite Rd", name: "Home", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "666 Favorite Ave", name: "Favorite Hotel 1", latitude: 34.0522, longitude: -118.2437, city: "Redwood"), name: "Scenic California Mountain Route"),
        Trip(start_location: Restaurant(address: "777 Favorite Rd", name: "Lorum ipsum Pebble Beach", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "888 Favorite Ave", name: "Favorite Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "San Francisco"), name: "LA to SF")
    ]
    
    var previous_trips = [
        Trip(start_location: Activity(address: "111 Old Rd", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "222 Old Ave", name: "Previous Hotel 1", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), name: "Cool Restaurants"),
        Trip(start_location: Restaurant(address: "333 Old Rd", name: "Lorum Ipsum Pebble Beach, CA", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "444 Old Ave", name: "Previous Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "Orlando"), name: "ATL to Orlando")
    ]
    
    var my_trips = [
        Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville"),
        Trip(start_location: Activity(address: "123 Start St", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "456 End Ave", name: "End Hotel", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), name: "Cross Country"),
        Trip(start_location: Activity(address: "789 Another St", name: "Johnson Family Spring Retreat", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "123 Another Ave", name: "Another Hotel", latitude: 34.0522, longitude: -118.2437, city: "Blue Ridge"), name: "GA Mountains")
    ]
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapView(mapManager: mapManager)
                .tabItem {
                    Label("Navigation", systemImage: "map.fill")
                }
                .tag(1)

            ExploreTripsView(mapManager: mapManager, vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard", trips: my_trips)), trips: my_trips, previousTrips: previous_trips, communityTrips: community_trips)
                .tabItem {
                    Label("Plan", systemImage: "pencil")
                }
                .tag(2)

            RecapView()
                .tabItem {
                    Label("Recaps", systemImage: "play.square.stack")
                }
                .tag(3)
        }.environmentObject(mapManager)
            .task {
                if !mapboxSetUp {
                    self.mapboxSetUp = true
                    await mapManager.setupMapbox()
                }
            }
    }
}

#Preview {
    RootView()
}
