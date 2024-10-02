//
//  FindStopView 2.swift
//  Nomad
//
//  Created by Brayden Huguenard on 10/1/24.
//

import SwiftUI

struct FindStopView: View {
    @ObservedObject var vm: UserViewModel
    @State var selection: String = "Food and Drink"
    @State var selectedCuisine: String = "All"
    @State var selectedRating: Double? = nil
    @State var selectedPrice: Int? = nil
    @State private var searchTerm: String = ""
    
    @State private var isLoading: Bool = false
    @State private var hasSearched: Bool = false
    
    let stop_types = ["Food and Drink", "Activities", "Scenic", "Hotels", "Tours and Landmarks", "Entertainment", "General"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Filter Stop Type")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Picker("Select a stop type", selection: $selection) {
                ForEach(stop_types, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            if selection == "Food and Drink" {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cuisine")
                        .font(.headline)
                    Picker("Cuisine", selection: $selectedCuisine) {
                        Text("All").tag("All")
                        Text("Italian").tag("Italian")
                        Text("Chinese").tag("Chinese")
                        Text("Mexican").tag("Mexican")
                        Text("American").tag("American")
                        Text("Barbecue").tag("Barbecue")
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Rating")
                        .font(.headline)
                    Picker("Rating", selection: $selectedRating) {
                        Text("Any").tag(nil as Double?)
                        Text("⭐️ 1").tag(1.0)
                        Text("⭐️⭐️ 2").tag(2.0)
                        Text("⭐️⭐️⭐️ 3").tag(3.0)
                        Text("⭐️⭐️⭐️⭐️ 4").tag(4.0)
                        Text("⭐️⭐️⭐️⭐️⭐️ 5").tag(5.0)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Price")
                        .font(.headline)
                    Picker("Price", selection: $selectedPrice) {
                        Text("Any").tag(nil as Int?)
                        Text("$").tag(1)
                        Text("$$").tag(2)
                        Text("$$$").tag(3)
                        Text("$$$$").tag(4)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rating")
                        .font(.headline)
                    Picker("Rating", selection: $selectedRating) {
                        Text("Any").tag(nil as Double?)
                        Text("⭐️ 1").tag(1.0)
                        Text("⭐️⭐️ 2").tag(2.0)
                        Text("⭐️⭐️⭐️ 3").tag(3.0)
                        Text("⭐️⭐️⭐️⭐️ 4").tag(4.0)
                        Text("⭐️⭐️⭐️⭐️⭐️ 5").tag(5.0)
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(.horizontal)
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
                    searchTerm = "Landmarks"
                case "Entertainment":
                    searchTerm = "Entertainment"
                case "General": // New case for general locations
                    searchTerm = "Business"
                default:
                    searchTerm = ""
                }
                
                Task {
                    do {
                        await vm.fetchPlaces(
                            location: "177 North Avenue NW, Atlanta, GA 30332",
                            stopType: searchTerm,
                            rating: selectedRating,
                            price: selectedPrice,
                            cuisine: selectedCuisine
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
                            Text("Rating: \(restaurant.rating ?? 0.0)")
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
                            Text("Rating: \(hotel.rating ?? 0.0)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("Price: \(hotel.price ?? 0)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                } else if selection == "Activities", !vm.activities.isEmpty {
                    List(vm.activities) { activity in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(activity.name)
                                .font(.headline)
                            Text(activity.address)
                                .font(.subheadline)
                            Text("Rating: \(activity.rating ?? 0.0)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                } else if selection == "General", !vm.generalLocations.isEmpty {
                    List(vm.generalLocations) { location in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(location.name)
                                .font(.headline)
                            Text(location.address)
                                .font(.subheadline)
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
        }
        .padding(.horizontal)
    }
}

#Preview {
    FindStopView(vm: .init(user: User(id: "89379", name: "Austin", trips: [Trip(start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"))])))
}
