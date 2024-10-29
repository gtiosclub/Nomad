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
    @State private var searchString: String = ""
    @State private var price: Int = 0
    @State private var rating: Int = 0
    @State private var selectedCuisines: [String] = []
    @State private var isLoading: Bool = false
    @State private var hasSearched: Bool = false
    @State private var stopName: String = ""
    @State private var stopAddress: String = ""
    @State private var selectedStop: (any POI)?
    @State private var isEditing: Bool = false
    @State private var routeProgress: Double = 0.0
    @State private var markerCoordinate: CLLocationCoordinate2D = .init(latitude: 0, longitude: 0)
    @State private var filterRating: String = "4 ★ and up"
    @State private var filterCuisine: String = "American"
    @State private var filterPrice: String = "$$"
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
                    RoutePreviewView(vm: vm, trip: Binding.constant(trip), currentLocation: markerCoordinate)
                        .frame(minHeight: 250.0)
                } else {
                    Text("No current trip available")
                        .foregroundColor(.red)
                }
            }
            
            VStack(alignment: .leading, spacing: 15) {
                /*Slider(value: $routeProgress, in: 0...1, step: 0.01) {
                 Text("Route Progress")
                 }
                 .padding()
                 .onChange(of: routeProgress) { newValue in
                 updateMarkerPosition(progress: newValue)
                 }*/
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
                    listCuisines //Lists out stops type that can be selected
                }
                .padding(5)
                
                Divider()
                
                TabView {
                    VStack(alignment: .leading, spacing: 16) {
                        if selection == "Restaurants" {
                            Text("Cuisine:")
                                .font(.headline)
                            FilterView(selectedRating: $rating, selectedCuisine: $selectedCuisines, selectedPrice: $price)
                        } else if selection == "Activities" || selection == "Hotels" {
                            RatingUI(rating: $rating)
                                .padding(.top, 10)
                        } else {
                            EnhancedRoutePlanListView(vm: vm)
                        }
                    }
                    .padding(.horizontal)
                    if selection == "Restaurants" || selection == "Activities" || selection == "Hotels" {
                        EnhancedRoutePlanListView(vm: vm)
                    }
                }
                .frame(height: selection == "Restaurants" ? 250 : (selection == "Activities" || selection == "Hotels" ? 80 : 300))
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle())
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                        .padding(.leading, 10)
                    TextField("Search stops...", text: $searchString)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 10)
                        .background(.white)
                        .cornerRadius(8)
                        .padding(.trailing, 10)
                }
                .padding(.horizontal, 30)
                .background(.white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray, lineWidth: 1)
                        .padding(.horizontal, 30)
                )
                
                fetchResults //Runs parameters through yelp api when search button is clicked
                
                ScrollView {
                    if isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else {
                        if hasSearched {
                            if (!getVM().isEmpty) {
                                ForEach(getVM(), id: \.id) { stop in
                                    ListQueryResults(stop: stop, selection: selection, addStop: addStop)
                                }
                            } else {
                                Text("No results found.")
                                    .foregroundColor(.secondary)
                                    .padding(.top)
                            }
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
    
    private var listCuisines: some View {
        let rows = stop_types.chunked(into: 4)
        return ForEach(rows, id: \.self) { row in
            HStack {
                ForEach(row, id: \.self) { option in
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
                }
            }
        }
    }
    
    private var fetchResults: some View {
        Button(action: {
            isLoading = true
            hasSearched = true
            
            Task {
                do {
                    await vm.fetchPlaces(
                        location: //vm.current_trip?.getStartLocation() ??
                        "177 North Avenue NW, Atlanta, GA 30332",
                        stopType: selection,
                        rating: Double(rating),
                        price: price,
                        cuisine: selectedCuisines.joined(separator: ","),
                        searchString: searchString
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
                //markerCoordinate = vm.current_trip?.getStartLocationCoordinates()
        }
        .padding()
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
    
    private func getVM() -> [any POI] {
        switch selection {
        case "Restaurants":
            return vm.restaurants
        case "Hotels":
            return vm.hotels
        case "Activities":
            return vm.activities
        case "Shopping":
            return vm.shopping
        default:
            return vm.generalLocations
        }
    }
    
    func addStop(_ stop: any POI) {
        Task {
            await vm.addStop(stop: stop)
            await self.updateTripRoute()
        }
    }
    
    struct RatingUI: View {
        @Binding var rating: Int
        
        var body: some View {
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
    
    struct ListQueryResults: View {
        var stop: any POI
        var selection: String
        var addStop: (any POI) -> Void
        
        private func showRating(_ rating: Double?) -> some View {
            Group {
                if let rating = rating {
                    HStack(spacing: 2) {
                        Text("\(String(format: "%.1f", rating))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Image(systemName: "star")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Rating: N/A")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }

        var body: some View {
            HStack {
                Button(action: { addStop(stop) }) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                        Image(systemName: "plus")
                            .foregroundColor(.gray)
                            .font(.system(size: 18))
                            .bold()
                    }
                }
                
                if let imageableStop = stop as? Imagable {
                    AsyncImage(url: URL(string: imageableStop.getImageUrl() ?? "")) { image in
                        image.resizable()
                            .frame(width: 70, height: 70)
                            .cornerRadius(10)
                            .clipped()
                    } placeholder: {
                        ProgressView().frame(width: 70, height: 70)
                    }
                } else {
                    Color.clear.frame(width: 70, height: 70)
                }

                VStack(alignment: .leading) {
                    Text(stop.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(stop.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    HStack {
                        if let restaurant = stop as? Restaurant {
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
                    }
                    
                    if let restaurant = stop as? Restaurant {
                        showRating(restaurant.rating)
                    } else if let activity = stop as? Activity {
                        showRating(activity.rating)
                    } else if let hotel = stop as? Hotel {
                        showRating(hotel.rating)
                    }
                }
                .padding(.vertical, 12)

                Spacer()
            }
            .padding(2)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    /*func updateMarkerPosition(progress: Double) {

        let totalTime = vm.total_time
        let targetTime = totalTime * progress

        Task {
            if let newPosition = try? await vm.mapManager.getFutureLocation(time: targetTime) {
                markerCoordinate = newPosition
            }
        }
    }*/
}

extension Array {
    public func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    var current_trip = Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta, GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)])
    
    var vm: UserViewModel = UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard", trips: [current_trip]))
    
    vm.setCurrentTrip(trip: current_trip)
    
    return FindStopView(vm: vm)
}
