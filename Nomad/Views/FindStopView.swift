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
    @State private var price: Int = 0
    @State private var rating: Int = 0
    @State private var selectedCuisines: [String] = []
    let cuisines = ["Chinese", "Italian", "Indian", "American", "Japanese", "Korean"]
    
    var body: some View {
        HStack {
            Text("Filter Stop Type")
            VStack {
                Picker("Select a stop type", selection: $selection) {
                    ForEach(stop_types, id: \.self) {
                        Text($0)
                    }
                }
                
                
                .pickerStyle(.menu)
                if selection == "Activities" {
                    VStack {
                        Text ("Rating: ")
                        Picker("Select Rating", selection: $rating) {
                            ForEach(1...5, id: \.self) {rating in
                                Text("\(rating) stars").tag(rating)
                            }
                        }

                    }
                }
                
                if selection == "Hotels" {
                    HStack {
                        Text("Rating:")
                        Picker("Select Rating", selection: $rating) {
                            ForEach(1...5, id: \.self) {rating in
                                Text("\(rating) stars").tag(rating)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                
                if selection == "Food and Drink" {
                    HStack{
                        
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
                        VStack {
                            Text("Price: ")
                            Picker("Select Price", selection: $price) {
                                ForEach(1...4, id: \.self) { dollarSign in
                                    Text(String(repeating: "$", count: dollarSign))
                                }
                            }
                            
                        }
                        
                        //rating selection
                        VStack {
                            Text ("Rating: ")
                            Picker("Select Rating", selection: $rating) {
                                ForEach(1...5, id: \.self) {rating in
                                    Text("\(rating) stars").tag(rating)
                                }
                            }

                        }
                        
                    }
                }
        
            }
    
    }


#Preview {
    FindStopView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "123 5th Street", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"))])))
}
