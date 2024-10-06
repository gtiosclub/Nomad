//
//  RootView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct RootView: View {
    @State var selectedTab = 2
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapView()
                .tabItem {
                    Label("Navigation", systemImage: "map.fill")
                }
                .tag(1)

            ItineraryPlanningView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard", trips: [Trip(start_location: Restaurant(address: "848 Spring Street Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)])])))
                .tabItem {
                    Label("Plan", systemImage: "pencil")
                }
                .tag(2)

            RecapView()
                .tabItem {
                    Label("Recaps", systemImage: "play.square.stack")
                }
                .tag(3)
        }
    }
}

#Preview {
    RootView()
}
