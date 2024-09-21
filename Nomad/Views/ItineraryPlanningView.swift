//
//  ItineraryPlanningView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct ItineraryPlanningView: View {
    @State var showText: Bool = false
    @ObservedObject var vm: UserViewModel
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button("Start Planning") {
            vm.addTripToUser(trip: .init(start_location: Restaurant(address: "123 street", name: "Tiffs", rating: 3.2), end_location: Hotel(address: "387 West Peachtree", name: "Hilton")))
        }
        ForEach(vm.getTrips()) { trip in
            Text(trip.start_location.name)
        }
    }
}

#Preview {
    ItineraryPlanningView(vm: .init(user: User(id: "austin")))
}
