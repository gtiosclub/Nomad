//
//  FindStopView.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/22/24.
//

import SwiftUI
import CoreLocation

struct FindStopView: View {
    @ObservedObject var vm: UserViewModel
    @State var selection: String = "Restaurants"
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
    @Environment(\.dismiss) var dismiss
    
    let stop_types = ["Restaurants", "Activities", "Scenic", "Hotels", "Tours & Landmarks", "Entertainment", "Shopping"]
    let cuisines = ["Chinese", "Italian", "Indian", "American", "Japanese", "Korean"]
    
    var body: some View {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Let's Plan Your New Trip")
                        .font(.headline)
                        .padding(.vertical, 5)
                        .padding(.horizontal)
                  
                    if let trip = vm.current_trip {
                        RoutePreviewView(vm: vm, trip: Binding.constant(trip))
                            .frame(minHeight: 250.0)
                    } else {
                        Text("No current trip available")
                            .foregroundColor(.red)
                    }
                }
                
                VStack(alignment: .leading, spacing: 15) {
                    HStack {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 24, height: 24)
                                .overlay {
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                            
                            Text("3")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        .padding(.leading)
                        
                        Text("Explore Stops")
                            .font(.headline)
                            .padding(.bottom, 5)
                            .offset(x: 12, y: 3)
                    }
                    
                    VStack(spacing: 8) {
                        HStack {
                            ForEach(stop_types.prefix(4), id: \.self) { option in
                                Button(action: {
                                    selection = option
                                }) {
                                    Text(option)
                                        .padding(8)
                                        .background(selection == option ? Color.gray : Color.gray.opacity(0))
                                        .foregroundColor(selection == option ? Color.white : Color.black)
                                        .cornerRadius(8)
                                        .font(.system(size: 14))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(width: 90, height: 30)
                                .cornerRadius(20)
                            }
                        }
                        
                        HStack() {
                            ForEach(stop_types.dropFirst(4), id: \.self) { option in
                                Button(action: {
                                    selection = option
                                }) {
                                    Text(option)
                                        .padding(8)
                                        .background(selection == option ? Color.gray : Color.gray.opacity(0))
                                        .foregroundColor(selection == option ? Color.white : Color.black)
                                        .cornerRadius(8)
                                        .font(.system(size: 14))
                                }
                                .buttonStyle(PlainButtonStyle())
                                .frame(width: 100, height: 30)
                                .cornerRadius(20)
                            }
                        }
                    }
                    .padding(5)
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        if selection == "Restaurants" {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Cuisine:")
                                    .font(.headline)
                                
                                HStack(alignment: .top, spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(cuisines, id: \.self) { cuisine in
                                            Button(action: {
                                                if selectedCuisines.contains(cuisine.lowercased()) {
                                                    selectedCuisines.removeAll { $0 == cuisine.lowercased() }
                                                } else {
                                                    selectedCuisines.append(cuisine.lowercased())
                                                }
                                            }) {
                                                HStack {
                                                    Image(systemName: selectedCuisines.contains(cuisine.lowercased()) ? "checkmark.square.fill" : "square")
                                                        .foregroundColor(selectedCuisines.contains(cuisine.lowercased()) ? .blue : .gray)
                                                    Text(cuisine)
                                                }
                                                .padding(.vertical, 4)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                        }
                                    }
                                    
                                    Spacer()
                                    
                                    VStack(alignment: .leading, spacing: 16) {
                                        VStack(alignment: .leading) {
                                            Text("Maximum Price:")
                                                .font(.subheadline)
                                                .bold()
                                            
                                            HStack(spacing: 8) {
                                                ForEach(1...4, id: \.self) { index in
                                                    Image(systemName: index <= price ? "dollarsign.circle.fill" : "dollarsign.circle")
                                                        .resizable()
                                                        .frame(width: 24, height: 24)
                                                        .foregroundColor(index <= price ? .green : .gray)
                                                        .onTapGesture {
                                                            price = index
                                                        }
                                                }
                                            }
                                        }
                                        
                                        VStack(alignment: .leading) {
                                            Text("Minimum Rating:")
                                                .font(.subheadline)
                                                .bold()
                                            
                                            HStack(spacing: 8) {
                                                ForEach(1...5, id: \.self) { index in
                                                    Image(systemName: index <= rating ? "star.fill" : "star")
                                                        .resizable()
                                                        .frame(width: 24, height: 24)
                                                        .foregroundColor(index <= rating ? .yellow : .gray)
                                                        .onTapGesture {
                                                            rating = index
                                                        }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.bottom, 10)
                        }
                        
                        if selection == "Activities" || selection == "Hotels" {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Minimum Rating:")
                                    .font(.headline)
                                
                                HStack(spacing: 12) {
                                    ForEach(1...5, id: \.self) { index in
                                        Image(systemName: index <= rating ? "star.fill" : "star")
                                            .resizable()
                                            .frame(width: 24, height: 24)
                                            .foregroundColor(index <= rating ? .yellow : .gray)
                                            .onTapGesture {
                                                rating = index
                                            }
                                    }
                                }
                            }
                            .padding(.top, 10)
                        }
                    }
                    .padding(.horizontal)
                    
                    Button(action: {
                        isLoading = true
                        hasSearched = true
                        
                        Task {
                            do {
                                await vm.fetchPlaces(
                                    location: "177 North Avenue NW, Atlanta, GA 30332",
                                    stopType: selection,
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
                    
                    ScrollView {
                        if isLoading {
                            ProgressView("Loading...")
                                .padding()
                        } else {
                            if selection == "Restaurants", !vm.restaurants.isEmpty {
                                ForEach(vm.restaurants) { restaurant in
                                    HStack {
                                        Button(action: {
                                            addStop(restaurant)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 24, height: 24)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                                Image(systemName: "plus")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 18))
                                                    .bold()
                                            }
                                        }
                                        
                                        AsyncImage(url: URL(string: restaurant.imageUrl ?? "")) { image in
                                            image
                                                .resizable()
                                                .frame(width: 70, height: 70)
                                                .cornerRadius(10)
                                                .clipped()
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 70, height: 70)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 0) {
                                            Text(restaurant.name)
                                                .font(.headline)
                                                .lineLimit(1)
                                            HStack(spacing: 1) {
                                                Text(restaurant.cuisine ?? "")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.secondary)
                                                
                                                if let city = restaurant.city {
                                                    Text(" • \(city) • ")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.secondary)
                                                }
                                                
                                                if let price = restaurant.price {
                                                    Text(String(repeating: "$", count: price))
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                            if let rating = restaurant.rating {
                                                HStack(spacing: 1) {
                                                    Text("\(String(format: "%.1f", rating))")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                    Image(systemName: "star")
                                                        .resizable()
                                                        .frame(width: 14, height: 14)
                                                        .foregroundColor(.secondary)
                                                }
                                            } else {
                                                Text("N/A")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.vertical, 12)
                                        Spacer()
                                    }
                                    .padding(2)
                                    .frame(minHeight: 50)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            } else if selection == "Hotels", !vm.hotels.isEmpty {
                                ForEach(vm.hotels) { hotel in
                                    HStack {
                                        Button(action: {
                                            addStop(hotel)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 24, height: 24)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                                Image(systemName: "plus")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 14))
                                                    .bold()
                                            }
                                        }
                                        AsyncImage(url: URL(string: hotel.imageUrl ?? "")) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 70, height: 70)
                                                .cornerRadius(8)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 70, height:70)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(hotel.name)
                                                .font(.headline)
                                            Text(hotel.address)
                                                .font(.subheadline)
                                            if let rating = hotel.rating {
                                                HStack(spacing: 1) {
                                                    Text("\(String(format: "%.1f", rating))")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                    Image(systemName: "star")
                                                        .resizable()
                                                        .frame(width: 14, height: 14)
                                                        .foregroundColor(.secondary)
                                                }
                                            } else {
                                                Text("N/A")
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        Spacer()
                                    }
                                    .padding(2)
                                    .frame(minHeight: 50)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            } else if selection == "Activities", !vm.activities.isEmpty {
                                ForEach(vm.activities) { activity in
                                    HStack() {
                                        Button(action: {
                                            addStop(activity)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 24, height: 24)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                                Image(systemName: "plus")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 14))
                                                    .bold()
                                            }
                                        }
                                        AsyncImage(url: URL(string: activity.imageUrl ?? "")) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 70, height: 70)
                                                .cornerRadius(8)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 70, height: 70)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(activity.name)
                                                .font(.headline)
                                            HStack(spacing: 1) {
                                                if let city = activity.city {
                                                    Text("\(city) • ")
                                                        .font(.system(size: 16))
                                                        .foregroundColor(.secondary)
                                                }
                                                if let rating = activity.rating {
                                                    HStack(spacing: 1) {
                                                        Text("\(String(format: "%.1f", rating))")
                                                            .font(.subheadline)
                                                            .foregroundColor(.secondary)
                                                        Image(systemName: "star")
                                                            .resizable()
                                                            .frame(width: 14, height: 14)
                                                            .foregroundColor(.secondary)
                                                    }
                                                } else {
                                                    Text("N/A")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        Spacer()
                                    }
                                    .padding(2)
                                    .frame(minHeight: 50)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            } else if selection == "Shopping", !vm.shopping.isEmpty {
                                ForEach(vm.shopping) { shop in
                                    HStack {
                                        Button(action: {
                                            addStop(shop)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 24, height: 24)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                                Image(systemName: "plus")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 14))
                                                    .bold()
                                            }
                                        }
                                        AsyncImage(url: URL(string: shop.imageUrl ?? "")) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 70, height: 70)
                                                .cornerRadius(8)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 70, height: 70)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(shop.name)
                                                .font(.headline)
                                            if let city = shop.city {
                                                Text("\(city)")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        Spacer()
                                    }
                                    .padding(2)
                                    .frame(minHeight: 50)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                }
                            } else if !vm.generalLocations.isEmpty {
                                ForEach(vm.generalLocations) { generalLocation in
                                    HStack {
                                        Button(action: {
                                            addStop(generalLocation)
                                        }) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 24, height: 24)
                                                    .overlay(
                                                        Circle()
                                                            .stroke(Color.gray, lineWidth: 1)
                                                    )
                                                Image(systemName: "plus")
                                                    .foregroundColor(.gray)
                                                    .font(.system(size: 14))
                                                    .bold()
                                            }
                                        }
                                        AsyncImage(url: URL(string: generalLocation.imageUrl ?? "")) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 70, height: 70)
                                                .cornerRadius(8)
                                        } placeholder: {
                                            ProgressView()
                                                .frame(width: 70, height: 70)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(generalLocation.name)
                                                .font(.headline)
                                            if let city = generalLocation.city {
                                                Text("\(city)")
                                                    .font(.system(size: 16))
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        .padding(.vertical, 8)
                                        Spacer()
                                    }
                                    .padding(2)
                                    .frame(minHeight: 50)
                                    .background(Color.white)
                                    .cornerRadius(12)
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
                    .frame(height: 300)
                    
                    NavigationLink(destination: PreviewRouteView(vm: vm, trip: vm.current_trip!)) {
                        Text("Continue").font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.top, 20)
            }.onAppear() {
                Task {
                    await updateTripRoute()
                }
        }
    }
    
    func removeStop(stop: any POI) async {
        vm.current_trip?.removeStops(removedStops: [stop])
        await self.updateTripRoute()
    }
    
    func replaceStop(oldStop: any POI, newStop: any POI) async {
        vm.current_trip?.removeStops(removedStops: [oldStop])
        vm.current_trip?.addStops(additionalStops: [newStop])
        await self.updateTripRoute()
    }
    
    func updateTripRoute() async {
        guard let start_loc = vm.current_trip?.getStartLocation() else { return }
        guard let end_loc = vm.current_trip?.getEndLocation() else { return }
        guard let all_stops = vm.current_trip?.getStops() else { return }
        
        var all_pois: [any POI] = []
        all_pois.append(start_loc)
        all_pois.append(contentsOf: all_stops)
        all_pois.append(end_loc)
        
        if let newRoutes = await MapManager.manager.generateRoute(pois: all_pois) {
            
            vm.setTripRoute(route: newRoutes[0])
        }
    }
    
    func addStop(_ stop: any POI) {
        Task {
            await vm.addStop(stop: stop)
            await self.updateTripRoute()
        }
    }
}


#Preview {
    FindStopView(vm: .init(user: User(id: "austinhuguenard", name: "Austin Huguenard", trips: [Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta, GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)])])))
}
