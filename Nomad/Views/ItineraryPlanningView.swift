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
                                        .onChange(of: inputAddressStart) { _ in
                                            if !startAddressError.isEmpty {
                                                startAddressError = ""
                                            }
                                            if inputAddressStart != vm.currentAddress {
                                                lastEdited = .start
                                                mapSearch.searchTerm = inputAddressStart
                                            }
                                        }
                                    
                                    Button(action: {
                                        inputAddressStart = vm.currentAddress ?? ""
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
                                            .onChange(of: inputAddressEnd) { _ in
                                                if !endAddressError.isEmpty {
                                                    endAddressError = ""
                                                }
                                                lastEdited = .end
                                                mapSearch.searchTerm = inputAddressEnd
                                            }
                                        
                                        if !startAddressError.isEmpty {
                                            Text(startAddressError + endAddressError + bothAddressError)
                                                .foregroundColor(.red)
                                                .font(.caption)
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
                        .font(.headline)
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
                            isLoading = true
                            Task {
                                await createTrip("atlas")
                            }
                        }
                    }) {
                        if !generatingRoute {
                            Label("Generate with Atlas", systemImage: "wand.and.sparkles")
                                .font(.headline)
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
                        ItineraryParentView(vm: vm, cvm: ChatViewModel())
                    }
                    
                    Button(action: {
                        if !generatingRoute {
                            generatingRoute = true
                            Task {
                                await createTrip("manual")
                            }
                        }
                    }) {
                        if !generatingRoute && !isLoading {
                            Text("Continue").font(.headline)
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
                                    .font(.headline)
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
                        ItineraryParentView(vm: vm, cvm: ChatViewModel())
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
                print("filling out current trip info")
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
                .font(.headline)
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
            Task {
                var start_location = GeneralLocation(address: inputAddressStart, name: inputNameStart, latitude: startLatitude, longitude: startLongitude)
                
                start_location.imageUrl = await Trip.getCityImageAsync(location: start_location)
                
                var end_location = GeneralLocation(address: inputAddressEnd, name: inputNameEnd, latitude: endLatitude, longitude: endLongitude)
                
                end_location.imageUrl = await Trip.getCityImageAsync(location: end_location)
                
                await vm.createTrip(start_location: start_location, end_location: end_location, start_date: ItineraryPlanningView.dateToString(date: startDate), end_date: ItineraryPlanningView.dateToString(date: endDate), stops: [], start_time: ItineraryPlanningView.timeToString(date: startTime), coverImageURL: end_location.imageUrl!)
                
                if version == "atlas" {
                    await vm.aiVM.generateTripWithAtlas(userVM: vm)
                    await vm.updateRoute()
                }
                
                inputNameEnd = ""
                inputNameStart = ""
                inputAddressEnd = ""
                inputAddressStart = ""
                startDate = Date()
                endDate = Date()
                startTime = Date()
                startLatitude = 0.0
                startLongitude = 0.0
                endLatitude = 0.0
                endLongitude = 0.0
                if version == "atlas" {
                    editTripAtlas = true
                    isLoading = false
                } else {
                    editTripContinue = true
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
        func dropdownMenu(inputAddress: Binding<String>, inputName: Binding<String>, inputLatitude: Binding<Double>, inputLongitude: Binding<Double>) -> some View {
            if(!mapSearch.locationResults.isEmpty){
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(mapSearch.locationResults, id: \.self) { location in
                                Button {
                                    reverseGeo(location: location, inputAddress: inputAddress, inputLatitude: inputLatitude, inputLongitude: inputLongitude)
                                    inputName.wrappedValue = location.title
                                    isClicked = true
                                    lastEdited = .null
                                    mapSearch.locationResults.removeAll()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                        mapSearch.locationResults.removeAll()
                                        isClicked = false
                                    }
    
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
                                Divider()
                            }
                        }
                    }
                }
                .frame(height: 120)
                .background(Color.white)
                .shadow(radius: 5)
                .cornerRadius(10)
//                .padding(.horizontal, 10)
            }
        }
    
    func reverseGeo(location: MKLocalSearchCompletion, inputAddress: Binding<String>, inputLatitude: Binding<Double>, inputLongitude: Binding<Double>) {
            let searchRequest = MKLocalSearch.Request(completion: location)
            let search = MKLocalSearch(request: searchRequest)
            var coordinateK : CLLocationCoordinate2D?
            search.start { (response, error) in
                if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                    coordinateK = coordinate
                }
    
                if let c = coordinateK {
                    let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
    
                    inputLatitude.wrappedValue = c.latitude
                    inputLongitude.wrappedValue = c.longitude
                    CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
    
                        guard let placemark = placemarks?.first else {
                            let errorString = error?.localizedDescription ?? "Unexpected Error"
                            print("Unable to reverse geocode the given location. Error: \(errorString)")
                            return
                        }
    
                        let reversedGeoLocation = ReversedGeoLocation(with: placemark)
    
                        mapSearch.searchTerm = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName), \(reversedGeoLocation.city), \(reversedGeoLocation.state) \(reversedGeoLocation.zipCode)"
    
                        inputAddress.wrappedValue = mapSearch.searchTerm
    
                    }
                }
            }
        }
}

#Preview {
    ItineraryPlanningView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech", latitude: 33.771712, longitude: -84.392842), end_location: Hotel(address: "387 West Peachtree, Atlanta, GA", name: "Hilton", latitude: 33.763814, longitude: -84.387338))])))
}
