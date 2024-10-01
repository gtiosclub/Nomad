//
//  FindStopView.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/22/24.
//

import SwiftUI

struct FindStopView: View {
    @ObservedObject var vm: UserViewModel
    @State var selection: String = "Food and Drink"
    let stop_types = ["Food and Drink", "Activities", "Scenic", "Hotels", "Tours and Landmarks", "Entertainment"]
    
    @State private var stopName: String = ""
    @State private var stopAddress: String = ""
    @State private var selectedStop: POI?
    @State private var isEditing: Bool = false
    
    var body: some View {
            VStack(alignment: .leading) {
                Text("Filter Stop Type")
                    .font(.headline)
                    .padding(.bottom, 5)

                Picker("Select a stop type", selection: $selection) {
                    ForEach(stop_types, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .padding(.bottom, 10)

                TextField("Stop Name", text: $stopName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 5)

                TextField("Stop Address", text: $stopAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.bottom, 10)

                Button(isEditing ? "Update Stop" : "Add Stop") {
                    let newStop = GeneralLocation(address: stopAddress, name: stopName)

                    if isEditing, let stop = selectedStop {
                        vm.current_trip?.removeStops(removedStops: [stop])
                        vm.current_trip?.addStops(additionalStops: [newStop])
                    } else {
                        vm.current_trip?.addStops(additionalStops: [newStop])
                    }

                    stopName = ""
                    stopAddress = ""
                    isEditing = false
                    selectedStop = nil
                }
                .padding(.bottom, 10)

                List {
                    ForEach(vm.current_trip?.getStops().filter { $0.name.contains(selection) } ?? [], id: \.address) { stop in
                        HStack {
                            Text("\(stop.name) - \(stop.address)")
                            Spacer()
                            Button("Edit") {
                                stopName = stop.name
                                stopAddress = stop.address
                                selectedStop = stop
                                isEditing = true
                            }
                            .padding(.leading)

                            Button("Delete") {
                                vm.current_trip?.removeStops(removedStops: [stop])
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        if let index = indexSet.first {
                            let stopToDelete = vm.current_trip?.getStops().filter { $0.name.contains(selection) }[index]
                            if let stopToDelete = stopToDelete {
                                vm.current_trip?.removeStops(removedStops: [stopToDelete])
                            }
                        }
                    })
                }
            }
            .padding()
            .navigationTitle("Add/Edit Stop")
        }
    }

#Preview {
    FindStopView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "123 5th Street", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"))])))
}
