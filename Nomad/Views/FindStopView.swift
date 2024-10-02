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
    @State var selectedCuisine: String = "All"
    @State var selectedRating: Double? = nil
    @State var selectedPrice: Int? = nil
    @State private var searchTerm: String = ""
    
    @State private var isLoading: Bool = false
    @State private var hasSearched: Bool = false
    
    let stop_types = ["Food and Drink", "Activities", "Scenic", "Hotels", "Tours and Landmarks", "Entertainment"]
    @State private var price: Int = 0
    @State private var rating: Int = 0
    @State private var selectedCuisines: [String] = []
    let cuisines = ["Chinese", "Italian", "Indian", "American", "Japanese", "Korean"]
    
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

            if selection == "Activities" {
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

            if selection == "Hotels" {
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
                .padding()
            }

            if selection == "Food and Drink" {
                VStack{

                    //cuisine
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

                    //price selection
                    Text("Price: ")
                    HStack {
                        ForEach(1...4, id:\.self) {index in
                            Image(systemName: index <= price ? "dollarsign.circle.fill" : "dollarsign.circle").foregroundColor(index <= price ? .yellow: .gray)
                                .onTapGesture {
                                    price = index
                                }
                        }
                    }

                    //rating selection
                    HStack {
                        Text ("Rating: ")
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

        }
        .padding(.horizontal)
    }


#Preview {
    FindStopView(vm: .init(user: User(id: "89379", name: "Austin", trips: [Trip(start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"))])))
}
