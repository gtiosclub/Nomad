//
//  ItineraryPlanningView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct ItineraryPlanningView: View {
    @State var inputAddressStart: String = ""
    @State var inputAddressEnd: String = ""
    @State var inputNameStart: String = ""
    @State var inputNameEnd: String = ""
    @State var editTrip: Bool = false
    @ObservedObject var vm: UserViewModel
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                Section(content: {
                    Text("Create New Trip")
                        .frame(width: UIScreen.main.bounds.width - 20, alignment: .leading)
                        .font(.headline)
                        .padding()
                })
                                
                HStack {
                    Text("Start Location")
                    VStack {
                        TextField("Name", text: $inputNameStart)
                        TextField("Address", text: $inputAddressStart)
                    }
                }.padding()
                
                HStack {
                    Text("End Location")
                    VStack {
                        TextField("Name", text: $inputNameEnd)
                        TextField("Address", text: $inputAddressEnd)
                    }
                    
                }.padding()
                
                Button("Create Trip!") {
                    let newTrip = Trip(
                        start_location: Restaurant(address: inputAddressStart, name: inputNameStart, rating: 3.2),
                        end_location: Hotel(address: inputAddressEnd, name: inputNameEnd)
                    )
                    let trip = vm.createTrip(start: newTrip.start_location, end: newTrip.end_location)
                    vm.addTripToUser(trip: trip)
                    inputNameEnd = ""
                    inputNameStart = ""
                    inputAddressEnd = ""
                    inputAddressStart = ""
                    editTrip = true
                }
                .navigationDestination(isPresented: $editTrip, destination: {TripView(vm: vm, trip: vm.current_trip)})
                
                Spacer()
                
                Section(header: Text("View or Edit Trip")
                    .frame(width: UIScreen.main.bounds.width - 20, alignment: .leading)
                    .font(.headline)
                    .padding()
                ) {
                    ForEach(vm.getTrips(), id: \.id) { trip in
                        NavigationLink(trip.start_location.name + " to " + trip.end_location.name, destination: {TripView(vm: vm, trip: trip)})
                    }
                }
                
                Spacer()
                
            }
        }
    }
}

#Preview {
    ItineraryPlanningView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "123 5th Street", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"))])))
}
