//
//  RootView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            
            NavigationLink { ItineraryPlanningView(vm: UserViewModel(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "123 5th Street", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"))])))
            } label: {
                Text("Plan Itinerary!")
            }
        }
    }
}

#Preview {
    RootView()
}
