//
//  RootView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct RootView: View {
    @State var selectedTab = 2
    @ObservedObject static var mapManager = MapManager()
    @State private var mapboxSetUp: Bool = false
    
    static var community_trips = [
        Trip(start_location: Activity(address: "739 Garland Ave STE 134, Los Angeles CA 90017", name: "Home", latitude: 34.0508, longitude:  -118.2670, city: "Los Angeles"), end_location: Hotel(address: "7 Valley Green Camp Rd, Orick CA 95555", name: "Favorite Hotel 1", latitude: 41.3245, longitude: -124.0367, city: "Redwood"), name: "Redwood National Park"),
        Trip(start_location: Restaurant(address: "699 N Pebble Beach Dr, Crescent City CA 95531", name: "Pebble Beach, CA", latitude: 41.7646, longitude: -124.2242, city: "Crescent City"), end_location: Hotel(address: "5 Embarcadero Ctr, San Francisco CA 94111", name: "Favorite Hotel 2", latitude: 37.7975, longitude: -122.3949, city: "San Francisco"), name: "LA to SF"),
        Trip(start_location: Restaurant(address: "699 N Pebble Beach Dr, Crescent City CA 95531", name: "Pebble Beach, CA", latitude: 41.7646, longitude: -124.2242, city: "Crescent City"), end_location: Hotel(address: "4795 Sunshine Canyon Dr, Boulder CO 80302", name: "Previous Hotel 2", latitude: 40.0488, longitude: -105.3428, city: "Boulder"), name: "Colorado Mountains")
    ]
    
    static var previous_trips = [
        Trip(start_location: Activity(address: "2715 N Vermont Canyon Rd, Los Angeles CA 90027", name: "Scenic California Mountain Route", latitude: 34.1223, longitude: -118.2967, city: "Los Angeles"), end_location: Hotel(address: "555 Universal Hollywood Dr, Universal City CA 91608", name: "Previous Hotel 1", latitude: 34.1375, longitude: -118.3535, city: "Los Angeles"), name: "Cool Restaurants"),
        Trip(start_location: Restaurant(address: "699 N Pebble Beach Dr, Crescent City CA 95531", name: "Pebble Beach, CA", latitude: 41.7646, longitude: -124.2242, city: "Crescent City"), end_location: Hotel(address: "7500 Futures Dr, Orlando, FL 32819", name: "Previous Hotel 2", latitude: 28.4459, longitude:-81.4260, city: "Orlando"), name: "ATL to Orlando"),
        Trip(start_location: Restaurant(address: "699 N Pebble Beach Dr, Crescent City CA 95531", name: "Pebble Beach, CA", latitude: 41.7646, longitude: -124.2242, city: "Crescent City"), end_location: Hotel(address: "70 Causeway St, Boston, MA 02114", name: "Previous Hotel 2", latitude: 42.3754, longitude: -71.0675, city: "Boston"), name: "Northeast States")
    ]
    
    static var my_trips = [
        Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville"),
        Trip(start_location: Activity(address: "70 Causeway St, Boston MA 02114", name: "Previous Hotel 2", latitude: 42.3754, longitude: -71.0675, city: "Boston"), end_location: Hotel(address: "206 Western Ave W, Seattle WA 98119", name: "End Hotel", latitude: 47.6229, longitude: -122.3601, city: "Seattle"), name: "Cross Country"),
        Trip(start_location: Activity(address: "4953 Franklin Ave, Los Angeles CA 90027", name: "Johnson Family Spring Retreat", latitude: 34.1116, longitude: -118.2968, city: "Los Angeles"), end_location: Hotel(address: "50 W Main St, Blue Ridge GA 30513", name: "Another Hotel", latitude: 34.8688, longitude: -84.3232, city: "Blue Ridge"), name: "GA Mountains")
    ]
    
    @ObservedObject var vm = UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard", trips: RootView.my_trips))
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapView(mapManager: RootView.mapManager)
                .tabItem {
                    Label("Navigation", systemImage: "map.fill")
                }
                .tag(1)

            ExploreTripsView(mapManager: RootView.mapManager, vm: vm, trips: vm.getTrips(), previousTrips: RootView.previous_trips, communityTrips: RootView.community_trips)
                .tabItem {
                    Label("Plan", systemImage: "pencil")
                }
                .tag(2)

            RecapView()
                .tabItem {
                    Label("Recaps", systemImage: "play.square.stack")
                }
                .tag(3)
        }.environmentObject(RootView.mapManager)
            .task {
                if !mapboxSetUp {
                    self.mapboxSetUp = true
                    await RootView.mapManager.setupMapbox()
                }
            }
    }
}

#Preview {
    RootView()
}
