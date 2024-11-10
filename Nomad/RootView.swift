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
    @State private var mapboxSetUp: Bool = false
    
    @ObservedObject var vm = UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard", trips: UserViewModel.my_trips))
//    @ObservedObject var firebaseVM = FirebaseViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MapView(vm: vm)
                .tabItem {
                    Label("Navigation", systemImage: "map.fill")
                }
                .tag(1)

            ExploreTripsView(vm: vm)
                .tabItem {
                    Label("Plan", systemImage: "pencil")
                }
                .tag(2)

            RecapView(vm: vm)
                .tabItem {
                    Label("Recaps", systemImage: "play.square.stack")
                }
                .tag(3)
        }.environmentObject(vm)
            .task {
                if !mapboxSetUp {
                    self.mapboxSetUp = true
                    await MapManager.manager.setupMapbox()
                }
            }
    }
}

#Preview {
    RootView()
}
