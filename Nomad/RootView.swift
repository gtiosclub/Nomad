//
//  RootView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI
import MapKit

struct RootView: View {
    @State var selectedTab = 2
    @State var mapboxSetUp: Bool = false
    @ObservedObject var vm: UserViewModel
//    UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard"))
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapView(tabSelection: $selectedTab, vm: vm)
                .tabItem {
                    Label("Navigation", systemImage: "map.fill")
                }
                .tag(1)

            ExploreTripsView(vm: vm)
                .tabItem {
                    Label("Plan", systemImage: "pencil")
                }
                .tag(2)
            
            RecapView(vm: vm, header: "Your Memories")
                .tabItem {
                    Label("Memories", systemImage: "play.square.stack")
                }
                .tag(3)
        }.environmentObject(vm)
        .edgesIgnoringSafeArea(.all)
        .task {
            print("made it to root view")
            if !mapboxSetUp {
                self.mapboxSetUp = true
                await MapManager.manager.setupMapbox()
            }
        }.onChange(of: vm.navigatingTrip) { oldValue, newValue in
            if let newTrip = newValue {
                if let _ = newTrip.route {
                    self.selectedTab = 1
                }
            }
        }
        .tint(Color.nomadDarkBlue)
    }
}

#Preview {
    RootView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")))
}
