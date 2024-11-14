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
    @State var selectedTab = 1
    @State private var isCuisineDropdownOpen = false
    @State private var isRatingDropdownOpen = false
    @State private var isPriceDropdownOpen = false
    @Environment(\.dismiss) var dismiss
    @State var manualSearch: String = "Manual Search"
    var searchTypes = ["Manual Search", "Filter Search"]
    
    let stop_types = ["Restaurants", "Activities", "Rest Stops", "Hotels", "Tours & Landmarks", "Entertainment", "Shopping"]
    let cuisines = ["Chinese", "Italian", "Indian", "American", "Japanese", "Korean"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
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
                
                if let trip = vm.current_trip {
                    RoutePreviewView(vm: vm, trip: Binding.constant(trip), currentStopLocation: Binding.constant(markerCoordinate), showStopMarker: true)
                        .frame(minHeight: 250.0)
                } else {
                    Text("No current trip available")
                        .foregroundColor(.red)
                }
                
                TabView(selection: $selectedTab) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Time into Route")
                            .font(.headline)
                        
                        HStack {
                            Text("0 Mins")
                            VStack {
                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        Slider(
                                            value: $routeProgress,
                                            in: 0...((vm.current_trip?.route?.totalTime() ?? 60) / 60),
                                            step: 1
                                        )
                                        .padding(.top)
                                        .onChange(of: routeProgress) { newValue in
                                            updateMarkerPosition(progress: newValue)
                                        }
                                        
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 5)
                                                .fill(Color.gray)
                                                .frame(width: 75, height: 25)
                                                .offset(y: 5)
                                            
                                            Text("\(Int(routeProgress)) Mins")
                                                .foregroundColor(.white)
                                                .offset(y: 5)
                                            
                                            Triangle()
                                                .fill(Color.gray)
                                                .frame(width: 15, height: 10)
                                                .offset(y: 20) // Position the triangle below the rectangle
                                        }
                                        .offset(x: CGFloat(routeProgress) / CGFloat((vm.current_trip?.route?.totalTime() ?? 60) / 60) * (geometry.size.width - 25) - 25, y: -25)
                                        .frame(alignment: .center)
                                    }
                                    .offset(y: 10)
                                }
                                .frame(height: 80)
                            }
                            Text("\(Int((vm.current_trip?.route?.totalTime() ?? 60) / 60)) Mins")
                        }
                        .padding(.horizontal)
                        .frame(alignment: .center)
                        
                        VStack {
                            Picker("Flavor", selection: $manualSearch) {
                                ForEach(searchTypes, id: \.self) { type in
                                    Text(type)
                                }
                            }
                        }
                        .pickerStyle(.segmented)
                        .padding(.horizontal)
                        
                        if $manualSearch.wrappedValue == "Manual Search" {
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
                                .offset(y: -20)
                        } else {
                            VStack(spacing: 8) {
                                listCuisines //Lists out stops type that can be selected
                            }
                            .padding(5)
                            .padding(.bottom, 0)
                            
                            if selection == "Restaurants" {
                                ZStack {
                                    HStack() {
                                        Spacer(minLength: 2)
                                        
                                        FilterDropdownView(
                                            title: "Cuisine",
                                            options: cuisines,
                                            selectedOptions: $selectedCuisines,
                                            selectedOption: .constant(0),
                                            isDropdownOpen: $isCuisineDropdownOpen,
                                            allowsMultipleSelection: true
                                        )
                                        .frame(minWidth: 120)

                                        FilterDropdownView(
                                            title: "Rating",
                                            options: ["1 ★", "2 ★", "3 ★", "4 ★", "5 ★"],
                                            selectedOptions: .constant([]),
                                            selectedOption: $rating,
                                            isDropdownOpen: $isRatingDropdownOpen,
                                            allowsMultipleSelection: false
                                        )
                                        .frame(minWidth: 100)

                                        FilterDropdownView(
                                            title: "Price",
                                            options: ["$", "$$", "$$$", "$$$$"],
                                            selectedOptions: .constant([]),
                                            selectedOption: $price,
                                            isDropdownOpen: $isPriceDropdownOpen,
                                            allowsMultipleSelection: false
                                        )
                                        .frame(minWidth: 100)
                                        
                                        Spacer(minLength: 2)
                                    }
                                    .padding(.horizontal)
                                    .zIndex(1)
//                                    .offset(y: -30)
                                    
                                    fetchResults //Runs parameters through yelp api when search button is clicked
                                    .offset(y: 90)
                                    .zIndex(0)
                                }
                            } else if selection == "Activities" || selection == "Hotels" {
                                RatingUI(rating: $rating)
                                    .padding(.top, 10)
                                    .frame(alignment: .center)
                                
                                fetchResults //Runs parameters through yelp api when search button is clicked
                            } else {
                                fetchResults
                                    .offset(y: -20)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .tag(1)
                    
                    VStack {
                        HStack {
                            Text("Route Plan")
                                .font(.headline)
                                .padding(.horizontal)
                                .frame(alignment: .leading)
                            
                            Spacer()
                        }
                        
                        EnhancedRoutePlanListView(vm: vm)
                        Spacer()
                    }
                    .tag(2)
                }
                .frame(height: dynamicHeight(for: selectedTab))
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                
                
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
                        }
                    }
                }
                .frame(height: hasSearched ? 300 : nil)
                
                NavigationLink(destination: PreviewRouteView(vm: vm, trip: vm.current_trip!)) {
                    Spacer()
                    Text("Preview Route").font(.system(size: 16))
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: 140)
                        .background(Color.gray.opacity(0.05))
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 0.5)
                        )
                    Spacer()
                }
            }
            .padding(.top, 5)
        }.onAppear() {
            markerCoordinate = vm.current_trip?.getStartLocationCoordinates() ?? .init(latitude: 0, longitude: 0)
        }
        .navigationBarBackButtonHidden()
        .toolbar(.hidden, for: .navigationBar)
    }
    
    private func dynamicHeight(for tab: Int) -> CGFloat {
        var size: CGFloat = 0
        switch tab {
        case 1:
            if $manualSearch.wrappedValue == "Manual Search" {
                size = 150
            } else {
                
                if selection == "Restaurants" {
                    //                if (isCuisineDropdownOpen) {
                    //                    size = 240
                    //                } else if (isRatingDropdownOpen) {
                    //                    size = 200
                    //                } else if (isPriceDropdownOpen) {
                    //                    size = 170
                    //                }
                    size = 200
                    if isPriceDropdownOpen || isCuisineDropdownOpen || isRatingDropdownOpen {
                        size += 50
                    }
                } else if selection == "Activities" || selection == "Hotels" {
                    size = 150
                } else {
                    size = 90
                }
            }
        case 2:
            return 290 + CGFloat((vm.current_trip?.getStops().count ?? 0) * 95)
        default:
            return 300
        }
        
        if tab == 1 && $manualSearch.wrappedValue == "Filter Search" {
            size += 100
        }
        return size + 200
    }

    private var listCuisines: some View {
        let rows = stop_types.chunked(into: 4)
        return ForEach(rows, id: \.self) { row in
            HStack(spacing: 2) {
                Spacer()
                ForEach(row, id: \.self) { option in
                    Button(action: {
                        selection = option
                    }) {
                        Text(option)
                            .padding(8)
                            .background(selection == option ? Color.gray.opacity(0.4) : Color.gray.opacity(0))
                            .foregroundColor(Color.black)
                            .cornerRadius(12)
                            .font(.system(size: 14))
//                            .fixedSize()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                Spacer()
            }
            .padding(.bottom, 0)
        }
    }

    
    private var fetchResults: some View {
        Button(action: {
            isLoading = true
            hasSearched = true
            Task {
                do {
                    if let currentTrip = vm.current_trip {
                        let coordinates: CLLocationCoordinate2D
                        if (stopAddress.isEmpty) {
                            coordinates = markerCoordinate
                        } else {
                            let (latitude, longitude) = await vm.getCoordinates(for: stopAddress) ?? (markerCoordinate.latitude, markerCoordinate.longitude)
                            coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        }
                        
                        if (selection == "Rest Stops") {
                            await vm.fetchRestStops(
                                latitude: "\(coordinates.latitude)",
                                longitude: "\(coordinates.longitude)"
                            )
                        } else {
                            await vm.fetchPlaces(
                                latitude: "\(coordinates.latitude)",
                                longitude: "\(coordinates.longitude)",
                                stopType: selection,
                                rating: Double(rating),
                                price: price,
                                cuisine: selectedCuisines.joined(separator: ","),
                                searchString: searchString
                            )
                        }
                    }
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
        case "Rest Stops":
            return vm.reststops
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
    
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            path.closeSubpath()
            return path
        }
    }
    
    struct RatingUI: View {
        @Binding var rating: Int
        
        var body: some View {
            HStack() {
                Spacer()
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
                Spacer()
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
            HStack(spacing: 12) {
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
                        //ProgressView().frame(width: 70, height: 70)
                        Color.clear.frame(width: 70, height: 70)
                    }
                } else {
                    Color.clear.frame(width: 70, height: 70)
                }

                VStack(alignment: .leading, spacing: 0) {
                    Text(stop.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    Text(stop.address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    HStack {
                        if let restaurant = stop as? Restaurant {
                            Text(restaurant.cuisine ?? "")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            
                            if let city = restaurant.city {
                                Text("• \(city)")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
                            }
                            
                            if let price = restaurant.price {
                                Text("•")
                                    .font(.system(size: 16))
                                    .foregroundColor(.secondary)
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
                .padding(.vertical, 2)
                Spacer()
            }
            .padding(4)
            .background(Color.white)
            .cornerRadius(12)
        }
    }
    
    func updateMarkerPosition(progress: Double) {
        let targetTime = 60 * progress
        
        if let newPosition = MapManager.manager.getFutureLocation(time: targetTime, route: vm.current_trip!.route!) {
            markerCoordinate = newPosition
        }
    }
}

extension Array {
    public func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

#Preview {
    struct FindStopPreviewWrapper: View {
        @StateObject private var vm = UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard"))
        @State private var isLoading = true

        var body: some View {
            Group {
                if isLoading {
                    ProgressView("Loading trip...")
                } else {
                    FindStopView(vm: vm)
                }
            }
            .onAppear {
                Task {
                    await vm.createTrip(
                        start_location: Restaurant(
                            address: "848 Spring Street, Atlanta, GA 30308",
                            name: "Tiff's Cookies",
                            rating: 4.5,
                            price: 1,
                            latitude: 33.778033,
                            longitude: -84.389090
                        ),
                        end_location: Hotel(
                            address: "201 8th Ave S, Nashville, TN 37203 United States",
                            name: "JW Marriott",
                            latitude: 36.156627,
                            longitude: -86.780947
                        ),
                        start_date: "10-05-2024",
                        end_date: "10-05-2024",
                        stops: [
                            Activity(
                                address: "1720 S Scenic Hwy Chattanooga, TN 37409 United States",
                                name: "Ruby Falls",
                                latitude: 35.018901,
                                longitude: -85.339367
                            )
                        ]
                    )
                    isLoading = false
                }
            }
        }
    }
    return FindStopPreviewWrapper()
}

