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
    @State private var searchTerm: String = ""
    @State private var price: Int = 0
    @State private var rating: Int = 0
    @State private var selectedCuisines: [String] = []
    @State private var isLoading: Bool = false
    @State private var hasSearched: Bool = false
    @State private var stopName: String = ""
    @State private var stopAddress: String = ""
    @State private var selectedStop: (any POI)?
    @State private var isEditing: Bool = false
    
    let stop_types = ["Food and Drink", "Activities", "Scenic", "Hotels", "Tours and Landmarks", "Entertainment"]
    let cuisines = ["Chinese", "Italian", "Indian", "American", "Japanese", "Korean"]
    
    var body: some View {
        RoutePrevieView(vm: vm)
        
        VStack(alignment: .leading) {
            Text("Filter Stop Type")
                .font(.headline)
                .padding(.bottom, 5)
            
            Picker("Select a stop type", selection: $selection) {
                ForEach(stop_types, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            VStack {
                if selection == "Food and Drink" {
                    VStack {
                        Text("Cuisine: ")
                        ForEach(cuisines, id: \.self) { cuisine in
                            HStack {
                                Button(action: {
                                    if selectedCuisines.contains(cuisine) {
                                        selectedCuisines.removeAll { $0 == cuisine }
                                    } else {
                                        selectedCuisines.append(cuisine)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName:
                                                selectedCuisines.contains(cuisine) ? "checkmark.square" : "square")
                                        Text(cuisine)
                                    }
                                }
                            }
                        }
                    }
                    
                    Text("Price: ")
                    HStack {
                        ForEach(1...4, id:\.self) {index in
                            Image(systemName: index <= price ? "dollarsign.circle.fill" : "dollarsign.circle").foregroundColor(index <= price ? .yellow: .gray)
                                .onTapGesture {
                                    price = index
                                }
                        }
                    }
                }
                
                if selection == "Activities" || selection == "Hotels" || selection == "Food and Drink" {
                    Text ("Rating: ")
                    HStack {
                        ForEach(1...5, id:\.self) { index in
                            Image(systemName: index <= rating ? "star.fill": "star")
                                .foregroundStyle(index <= rating ? .yellow: .gray)
                                .onTapGesture {
                                    rating = index
                                }
                        }
                    }
                }
            }
            
            Button(action: {
                isLoading = true
                hasSearched = true
                
                var searchTerm: String
                switch selection {
                case "Food and Drink":
                    searchTerm = "Food"
                case "Activities":
                    searchTerm = "Activities"
                case "Scenic":
                    searchTerm = "Scenic"
                case "Hotels":
                    searchTerm = "Hotels"
                case "Tours and Landmarks":
                    searchTerm = "Tours and Landmarks"
                case "Entertainment":
                    searchTerm = "Entertainment"
                default:
                    searchTerm = ""
                }
                
                Task {
                    do {
                        await vm.fetchPlaces(
                            location: "177 North Avenue NW, Atlanta, GA 30332",
                            stopType: searchTerm,
                            rating: Double(rating),
                            price: price,
                            cuisine: selectedCuisines.joined(separator: ",")
                        )
                    }
                    isLoading = false
                }
            }) {
                HStack {
                    Spacer()
                    Text("Search")
                        .font(.headline)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    Spacer()
                }
            }
            .padding()
            
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else {
                if selection == "Food and Drink", !vm.restaurants.isEmpty {
                    List(vm.restaurants) { restaurant in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(restaurant.name)
                                .font(.headline)
                            Text(restaurant.address)
                                .font(.subheadline)
                            Text("Rating: \(String(format: "%.2f", restaurant.rating ?? 0.0))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Price: \(restaurant.price ?? 0)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                } else if selection == "Hotels", !vm.hotels.isEmpty {
                    List(vm.hotels) { hotel in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(hotel.name)
                                .font(.headline)
                            Text(hotel.address)
                                .font(.subheadline)
                            Text("Rating: \(String(format: "%.2f", hotel.rating ?? 0.0))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                        }
                        .padding(.vertical, 8)
                    }
                } else if selection == "Activities" && !vm.activities.isEmpty {
                    List(vm.activities) { activity in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activity.name)
                                .font(.headline)
                            Text("Rating: \(String(format: "%.2f", activity.rating ?? 0.0))")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                        }
                        .padding(.vertical, 8)
                    }
                } else if !vm.generalLocations.isEmpty {
                    List(vm.generalLocations) { generalLocation in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(generalLocation.name)
                                .font(.headline)
                        }
                        .padding(.vertical, 8)
                    }
                } else if hasSearched {
                    Text("No results found.")
                        .foregroundColor(.secondary)
                        .padding(.top)
                } else {
                    Text("Search for \(selection)")
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
            }
            
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
        .padding(.horizontal)
        .navigationTitle("Add/Edit Stop")
    }
}


#Preview {
    FindStopView(vm: .init(user: User(id: "89379", name: "Austin", trips: [Trip(start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"))])))
}
