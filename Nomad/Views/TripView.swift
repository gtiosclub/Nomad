//
//  TripView.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/21/24.
//

import SwiftUI

struct TripView: View {
    @ObservedObject var vm: UserViewModel
    @State var trip: Trip?
    @State var startDate: String = ""
    @State var endDate: String = ""
    
    @State private var startLocationName: String = ""
    @State private var startLocationAddress: String = ""
    @State private var endLocationName: String = ""
    @State private var endLocationAddress: String = ""
    
    var body: some View {
            NavigationStack {
                VStack(alignment: .center) {
                    Text("Edit Trip Details")
                        .font(.title)
                        .frame(width: UIScreen.main.bounds.width - 20, alignment: .topLeading)
                        .onAppear {
                            vm.setCurrentTrip(trip: trip!)
                            startLocationName = vm.current_trip?.getStartLocation().name ?? ""
                            startLocationAddress = vm.current_trip?.getStartLocation().address ?? ""
                            endLocationName = vm.current_trip?.getEndLocation().name ?? ""
                            endLocationAddress = vm.current_trip?.getEndLocation().address ?? ""
                        }
                    
                    Spacer(minLength: 20)
                    
                    Text("Your trip from \(vm.current_trip?.getStartLocation().name ?? "") to \(vm.current_trip?.getEndLocation().name ?? "")")
                        .frame(width: UIScreen.main.bounds.width - 20, alignment: .topLeading)
                    
                    VStack {
                        HStack {
                            TextField("Start Location Name", text: $startLocationName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Spacer()
                            TextField("Start Location Address", text: $startLocationAddress)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        HStack {
                            TextField("End Location Name", text: $endLocationName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            Spacer()
                            TextField("End Location Address", text: $endLocationAddress)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                    }
                    .padding()
                    
                    VStack {
                        TextField("Start Date", text: $startDate)
                        TextField("End Date", text: $endDate)
                    }
                    .padding()

                    VStack {
                        Button("Save Changes") {
                            if trip != nil {
                                vm.setStartLocation(new_start_location: GeneralLocation(address: startLocationAddress, name: startLocationName))
                                vm.setEndLocation(new_end_location: GeneralLocation(address: endLocationAddress, name: endLocationName))
                            }
                        }
                        .padding()
                        .padding()

                        Text("Stops")
                            .font(.headline)
                        
                        NavigationLink("Add a Stop", destination: { FindStopView(vm: vm)} )
                            
                        ForEach(vm.current_trip?.getStops() ?? [], id: \.address) { stop in
                            Text("\(stop.name)")
                        }
                    }
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)

                    Spacer()
                }
                .padding()
            }
        }
    }

#Preview {
    TripView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "123 5th Street", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"))])), trip: .init(start_location: Restaurant(address: "123 street", name: "Tiffs", rating: 3.2), end_location: Hotel(address: "387 West Peachtree", name: "Hilton")))
}
