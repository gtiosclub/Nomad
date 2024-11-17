//
//  ItineraryPlanningView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI
import CoreLocation
import MapKit

struct ItineraryPlanningView: View {
    @State var inputAddressStart: String = ""
    @State var inputAddressEnd: String = ""
    @State var inputNameStart: String = ""
    @State var inputNameEnd: String = ""
    @State var startLatitude: Double = 0
    @State var startLongitude: Double = 0
    @State var endLatitude: Double = 0
    @State var endLongitude: Double = 0
    @State var editTripAtlas: Bool = false
    @State var editTripContinue: Bool = false
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var startTime: Date = Date()
    @State private static var dateformatter = DateFormatter()
    @ObservedObject var vm: UserViewModel
    @ObservedObject var mapSearch = MapSearch()
    @State var isClicked: Bool = false
    @State var startAddressError: String = ""
    @State var endAddressError: String = ""
    @State var isLoading: Bool = false
    @State var bothAddressError: String = ""
    @State var generatingRoute: Bool = false
    
    var use_current_trip: Bool = false
    var letBack: Bool = true
    var newTrip: Bool
    
    enum completion {
        case null, start, end
    }
    
    @State var lastEdited: completion = .null
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    HStack {
                        Text("Let's plan your new trip")
                            .frame(alignment: .leading)
                            .font(.headline)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .offset(y: -280)
                    
                    HStack {
                        ItinerarySectionView(sectionNum: 1, sectionTitle: "Enter your route information")
                        Spacer()
                    }
                    .padding(.horizontal)
                    .offset(y: -230)
                    
                    VStack {
                        ZStack {
                            VStack(spacing: 15) {
                                ZStack {
                                    TextField("Start Location", text: $inputAddressStart)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .frame(height: 50)
                                        .onChange(of: inputAddressStart) { old, new in
                                            let commaCount = new.filter { $0 == "," }.count
                                            
                                            if commaCount != 2 {
                                                if !startAddressError.isEmpty {
                                                    startAddressError = ""
                                                }
                                                if inputAddressStart != vm.currentAddress {
                                                    lastEdited = .start
                                                    mapSearch.searchTerm = inputAddressStart
                                                }
                                            }
                                        }
                                    
                                    Button(action: {
                                        inputAddressStart = vm.currentAddress ?? ""
                                        inputNameStart = ""
                                        if !inputAddressStart.isEmpty {
                                            fetchCoordinates(for: inputAddressStart)
                                        }
                                        mapSearch.locationResults.removeAll()
                                    }, label: {
                                        Image(systemName: "location.fill")
                                            .foregroundColor(Color.nomadDarkBlue)
                                    })
                                    .frame(alignment: .trailing)
                                    .offset(x: 100)
                                }
                                
                                ZStack {
                                    VStack {
                                        TextField("End Location", text: $inputAddressEnd)
                                            .padding()
                                            .background(Color.white)
                                            .cornerRadius(10)
                                            .frame(height: 50)
                                            .onChange(of: inputAddressEnd) { old, new in
                                                let commaCount = new.filter { $0 == "," }.count
                                                
                                                if commaCount != 2 {
                                                    if !endAddressError.isEmpty {
                                                        endAddressError = ""
                                                    }
                                                    lastEdited = .end
                                                    mapSearch.searchTerm = inputAddressEnd
                                                }
                                            }
                                        
                                        if !startAddressError.isEmpty || !endAddressError.isEmpty || !bothAddressError.isEmpty {
                                            Text(startAddressError + endAddressError + bothAddressError)
                                                .foregroundColor(.red)
                                                .font(.caption)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                        }
                                    }
                                }
                            }
                            .padding(20)
                        }
                        .background(Color.nomadLightBlue)
                        .cornerRadius(15)
                        .padding()
                        .padding(.horizontal, 30)
                        .padding(.top, 0)
                        .zIndex(0)
                        .frame(maxHeight: 100)
                    }
                    .padding(.horizontal)
                    .offset(y: -110)
                    .frame(maxHeight: 100)
                
                    if (lastEdited == .start || lastEdited == .end) && !isClicked {
                        dropdownMenu(inputAddress: lastEdited == .start ? $inputAddressStart : $inputAddressEnd,
                                     inputName: lastEdited == .start ? $inputNameStart : $inputNameEnd,
                                     inputLatitude: lastEdited == .start ? $startLatitude : $endLatitude,
                                     inputLongitude: lastEdited == .start ? $startLongitude : $endLongitude)
                        .frame(width: UIScreen.main.bounds.width - 160, height: 120)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.horizontal, 30)
                        .offset(y: lastEdited == .start ? -50 : 20) // Adjust position relative to each field
                        .zIndex(1)
                    }
                    
                    HStack {
                        ItinerarySectionView(sectionNum: 2, sectionTitle: "Enter your dates")
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .offset(y: 20)
                    
                    VStack {
                        ZStack {
                            VStack {
                                HStack {
                                    Text("Departure")
                                        .padding()
                                    Spacer()
                                }
                                
                                HStack {
                                    DatePicker("", selection: $startDate, displayedComponents: [.date])
                                        .onChange(of: startDate) { oldValue, newValue in
                                            if startDate > endDate {
                                                endDate = startDate
                                            }
                                        }
                                    
                                    DatePicker("", selection: $startTime, displayedComponents: [.hourAndMinute])
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                
                                HStack {
                                    Text("Arrival")
                                        .padding()
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    DatePicker("", selection: $endDate, displayedComponents: [.date])
                                    
                                    Spacer(minLength: 115)
                                }
                                .padding(.horizontal)
                                .padding(.bottom)
                            }
                        }
                        .background(Color.nomadLightBlue)
                        .cornerRadius(15)
                        .padding()
                        .padding(.horizontal, 30)
                        .padding(.top, 0)
                    }
                    .padding(.horizontal)
                    .offset(y: 170)
                }
                .frame(height: 600)
                
                HStack {
                    Button(action: {
                        if !isLoading {
                            Task {
                                await createTrip("atlas")
                            }
                        }
                    }) {
                        if !generatingRoute && !use_current_trip {
                            Label(isLoading ? "Generating with Atlas" : "Generate with Atlas", systemImage: "wand.and.sparkles")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.purple]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(15)
                                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                    }
                    .navigationDestination(isPresented: $editTripAtlas) {
                        ItineraryParentView(vm: vm, cvm: ChatViewModel(), newTrip: newTrip)
                    }
                    
                    Button(action: {
                        if !generatingRoute {
                            Task {
                                await createTrip("manual")
                            }
                        }
                    }) {
                        if !generatingRoute && !isLoading {
                            Text("Continue")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.nomadDarkBlue)
                                .cornerRadius(15)
                                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                        } else if generatingRoute {
                            HStack {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                
                                Text("Generating Route")
                                    .font(.system(size: 18))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.nomadDarkBlue)
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                            .frame(minWidth: 300)
                        }
                    }
                    .navigationDestination(isPresented: $editTripContinue) {
                        ItineraryParentView(vm: vm, cvm: ChatViewModel(), newTrip: newTrip)
                    }
                    
                }
            }.overlay(
                Group {
                    if isLoading {
                        AtlasLoadingView(isAtlas: true)
                            .frame(width: 80, height: 80) // Adjust size if needed
                    }
                }
            )
        }.onAppear() {
            if !use_current_trip {
                vm.clearCurrentTrip()
            } else {
                startTime = timeFormatter(vm.current_trip?.getStartTime())
                startDate = dateFormatter(vm.current_trip?.getStartDate())
                endDate = dateFormatter(vm.current_trip?.getEndDate())
                inputAddressStart = vm.current_trip?.getStartLocation().address ?? ""
                inputAddressEnd = vm.current_trip?.getEndLocation().address ?? ""
                startLatitude = vm.current_trip?.getStartLocation().latitude ?? 0.0
                startLongitude = vm.current_trip?.getStartLocation().longitude ?? 0.0
                endLatitude = vm.current_trip?.getEndLocation().latitude ?? 0.0
                endLongitude = vm.current_trip?.getEndLocation().longitude ?? 0.0
                inputNameStart = vm.current_trip?.getStartLocation().name ?? ""
                inputNameEnd = vm.current_trip?.getEndLocation().name ?? ""
            }
        }
        .navigationBarBackButtonHidden(!letBack)
        .toolbar(letBack ? .visible : .hidden, for: .navigationBar)
        .environmentObject(mapSearch)
    }
    
    func timeFormatter(_ time: String?) -> Date {
        guard let time else { return Date() }
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "hh:mm a"
        
        if let date = timeFormat.date(from: time) {
            return date
        } else {
            return Date()
        }
    }
    
    func dateFormatter(_ date: String?) -> Date {
        guard let date else { return Date() }
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM-dd-yyyy"
        
        if let date = dateFormat.date(from: date) {
            return date
        } else {
            return Date()
        }
    }
    
    func fetchCoordinates(for address: String) {
        Task {
            if let coordinates = await vm.getCoordinates(for: address) {
                startLatitude = coordinates.0
                startLongitude = coordinates.1
            }
        }
    }
    
    struct ItinerarySectionView : View {
        var sectionNum: Int
        var sectionTitle: String
        
        var body: some View {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .overlay {
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                    }
                
                Text("\(sectionNum)")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            
            Text("\(sectionTitle)")
                .frame(alignment: .leading)
                .padding(.horizontal)
                .font(.system(size: 16))
        }
    }
    
    func createTrip(_ version: String) async {
        startAddressError = ""
        endAddressError = ""
        bothAddressError = ""
        
        if inputAddressStart.components(separatedBy: ",").count < 3 && inputAddressEnd.components(separatedBy: ",").count < 3 {
            bothAddressError = "Both addresses need to be entered with a street, city, and state."
        } else if inputAddressStart.components(separatedBy: ",").count < 3 {
            startAddressError = "Please enter a valid start location with a street, city, and state."
        } else if inputAddressEnd.components(separatedBy: ",").count < 3 {
            endAddressError = "Please enter a valid end location with a street, city, and state."
        }
        
        if inputAddressStart.contains(inputNameStart) || inputNameStart.isEmpty {
            inputNameStart = "Start Location"
        }
        if inputAddressEnd.contains(inputNameEnd) || inputNameEnd.isEmpty {
            inputNameEnd = "End Location"
        }
        
        if startAddressError.isEmpty && endAddressError.isEmpty && bothAddressError.isEmpty {
            if version == "manual" {
                generatingRoute = true
            } else {
                isLoading = true
            }
            
            if !use_current_trip {
                Task {
                    let start_location_base = GeneralLocation(
                        address: inputAddressStart,
                        name: inputNameStart,
                        latitude: startLatitude,
                        longitude: startLongitude
                    )
                    
                    let end_location_base = GeneralLocation(
                        address: inputAddressEnd,
                        name: inputNameEnd,
                        latitude: endLatitude,
                        longitude: endLongitude
                    )
                    
                    async let startImageUrl = Trip.getCityImageAsync(location: start_location_base)
                    async let endImageUrl = Trip.getCityImageAsync(location: end_location_base)
                    
                    let fetchedStartImageUrl = await startImageUrl
                    let fetchedEndImageUrl = await endImageUrl
                    
                    var start_location = start_location_base
                    var end_location = end_location_base
                    start_location.imageUrl = fetchedStartImageUrl
                    end_location.imageUrl = fetchedEndImageUrl
                    
                    await vm.createTrip(start_location: start_location, end_location: end_location, start_date: ItineraryPlanningView.dateToString(date: startDate), end_date: ItineraryPlanningView.dateToString(date: endDate), stops: [], start_time: ItineraryPlanningView.timeToString(date: startTime), coverImageURL: end_location.imageUrl!)
                    
                    if version == "atlas" {
                        await vm.aiVM.generateTripWithAtlas(userVM: vm)
                        await vm.updateRoute()
                    }
                    
                    if version == "atlas" {
                        editTripAtlas = true
                        isLoading = false
                    } else {
                        editTripContinue = true
                        generatingRoute = false
                    }
                }
            } else {
                vm.setStartDate(startDate: ItineraryPlanningView.dateToString(date: startDate))
                vm.setEndDate(endDate: ItineraryPlanningView.dateToString(date: endDate))
                vm.setStartTime(startTime: ItineraryPlanningView.timeToString(date: startTime))
                
                if inputAddressStart != vm.current_trip?.getStartLocation().address || inputAddressEnd != vm.current_trip?.getEndLocation().address {
                    Task {
                        if inputAddressStart != vm.current_trip?.getStartLocation().address {
                            var start_location = GeneralLocation(address: inputAddressStart, name: inputNameStart, latitude: startLatitude, longitude: startLongitude)
                            
                            start_location.imageUrl = await Trip.getCityImageAsync(location: start_location)
                            
                            vm.setStartLocation(new_start_location: start_location)
                        }
                        
                        if inputAddressEnd != vm.current_trip?.getEndLocation().address {
                            var end_location = GeneralLocation(address: inputAddressEnd, name: inputNameEnd, latitude: endLatitude, longitude: endLongitude)
                            
                            end_location.imageUrl = await Trip.getCityImageAsync(location: end_location)
                            
                            vm.setEndLocation(new_end_location: end_location)
                            vm.current_trip?.setImageUrl(imageUrl: end_location.imageUrl ?? "")
                        }
                        
                        await vm.updateRoute()
                        
                        editTripContinue = true
                        generatingRoute = false
                    }
                } else {
                    editTripContinue = true
                    generatingRoute = false
                }
            }
        }
    }
    
    static func dateToString(date: Date) -> String {
        dateformatter.dateFormat = "MM-dd-yyyy"
        return dateformatter.string(from: date)
    }
    
    static func timeToString(date: Date) -> String {
        dateformatter.dateFormat = "hh:mm a"
        return dateformatter.string(from: date)
    }
    
    @ViewBuilder
    func dropdownMenu(
        inputAddress: Binding<String>,
        inputName: Binding<String>,
        inputLatitude: Binding<Double>,
        inputLongitude: Binding<Double>
    ) -> some View {
        if !mapSearch.locationResults.isEmpty {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(mapSearch.locationResults, id: \.self) { location in
                            LocationRow(
                                location: location,
                                inputAddress: inputAddress,
                                inputName: inputName,
                                inputLatitude: inputLatitude,
                                inputLongitude: inputLongitude,
                                lastEdited: $lastEdited
                            )
                            Divider()
                        }
                    }
                }
            }
            .frame(height: 120)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
        }
    }
    
    struct LocationRow: View {
        var location: MKLocalSearchCompletion
        var inputAddress: Binding<String>
        var inputName: Binding<String>
        var inputLatitude: Binding<Double>
        var inputLongitude: Binding<Double>
        var lastEdited: Binding<completion>
        
        @EnvironmentObject var mapSearch: MapSearch
        @State private var isClicked: Bool = false

        var body: some View {
            Button {
                Task {
                    await selectLocation()
                }
                lastEdited.wrappedValue = .null
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text(location.title)
                            .foregroundColor(Color.black)
                            .multilineTextAlignment(.leading)
                        Text(location.subtitle)
                            .font(.caption)
                            .foregroundColor(Color.gray)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(.vertical, 5)
                    .padding(.leading, 10)
                    .padding(.trailing, 3)
                    Spacer()
                }
            }
        }
        
        private func selectLocation() async {
            await reverseGeo(location: location)
            inputName.wrappedValue = location.title
            isClicked = true
            mapSearch.locationResults.removeAll()
            lastEdited.wrappedValue = .null
        }
        
        private func reverseGeo(location: MKLocalSearchCompletion) async {
            do {
                if let (latitude, longitude, address) = await mapSearch.fetchLocationDetails(for: location) {
                    inputLatitude.wrappedValue = latitude
                    inputLongitude.wrappedValue = longitude
                    inputAddress.wrappedValue = address
                }
            }
        }
    }
}

extension MapSearch {
    func fetchLocationDetails(for location: MKLocalSearchCompletion) async -> (latitude: Double, longitude: Double, address: String)? {
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        
        // Attempt to start the search and retrieve the first result's coordinate
        guard let response = try? await search.start(),
              let coordinate = response.mapItems.first?.placemark.coordinate else {
            print("Failed to fetch search response or coordinate.")
            return nil
        }
        
        // Attempt reverse geocoding with CLLocation
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        guard let placemark = try? await CLGeocoder().reverseGeocodeLocation(location).first else {
            print("Failed to reverse geocode the coordinate.")
            return nil
        }
        
        // Construct the address from the placemark
        let address = "\(placemark.subThoroughfare ?? "") \(placemark.thoroughfare ?? ""), \(placemark.locality ?? ""), \(placemark.administrativeArea ?? "") \(placemark.postalCode ?? "")"
        
        return (coordinate.latitude, coordinate.longitude, address)
    }
}



#Preview {
    ItineraryPlanningView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech", latitude: 33.771712, longitude: -84.392842), end_location: Hotel(address: "387 West Peachtree, Atlanta, GA", name: "Hilton", latitude: 33.763814, longitude: -84.387338))])), newTrip: true)
}
