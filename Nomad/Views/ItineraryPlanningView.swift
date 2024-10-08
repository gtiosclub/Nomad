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
    @State var isClicked: Bool = false
    @State var inputAddressStart: String = ""
    @State var inputAddressEnd: String = ""
    @State var inputNameStart: String = ""
    @State var inputNameEnd: String = ""
    @State var startLatitude: Double = 0
    @State var startLongitude: Double = 0
    @State var endLatitude: Double = 0
    @State var endLongitude: Double = 0
    @State var editTrip: Bool = false
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var startTime: Date = Date()
    @State private static var dateformatter = DateFormatter()
    @ObservedObject var vm: UserViewModel
    @ObservedObject var mapSearch = MapSearch()
    
    enum completion{
        case null, start, end
    }
    
    @State var lastEdited: completion = .null
    
    var body: some View {
        NavigationStack {
            VStack {
                
                Section(content: {
                    Text("Let's plan your new trip")
                        .frame(width: UIScreen.main.bounds.width - 20, alignment: .leading)
                        .font(.headline)
                        .padding()
                })
                HStack{
                    ZStack{
                        Circle().fill(.black).frame(width: 21, height: 21)
                        Circle().fill(.white).frame(width: 19, height: 19)
                        Text("1")
                    }.padding(.horizontal)
                    Text("Enter your route information")
                }.padding(.horizontal)
                    .frame(width: UIScreen.main.bounds.width - 20, alignment: .leading)
                    .font(.headline)
                ZStack {
                    VStack(spacing: 15){
                        VStack{
                            TextField("Start Location", text: $inputAddressStart).padding().background(Color.white).cornerRadius(10)
                                .onChange(of: inputAddressStart) {
                                    lastEdited = .start
                                    mapSearch.searchTerm = inputAddressStart
                                }
                            
                        }
                        
                        ZStack{
                            TextField("End Location", text: $inputAddressEnd).padding().background(Color.white).cornerRadius(10)
                                .onChange(of: inputAddressEnd) {
                                    lastEdited = .end
                                    mapSearch.searchTerm = inputAddressEnd
                                }
                            if(lastEdited == completion.start && !isClicked){
                                dropdownMenu(inputAddress: $inputAddressStart, inputName: $inputNameStart, inputLatitude: $startLatitude, inputLongitude: $startLongitude)
                            }
                            
                        }
                        if(lastEdited == completion.end && !isClicked){
                            dropdownMenu(inputAddress: $inputAddressEnd, inputName: $inputNameEnd, inputLatitude: $endLatitude, inputLongitude: $endLongitude)
                        }
                    }.padding(20)
                }.background(Color.gray.opacity(0.5))
                    .cornerRadius(15)
                    .padding()
                HStack{
                    ZStack{
                        Circle().fill(.black).frame(width: 21, height: 21)
                        Circle().fill(.white).frame(width: 19, height: 19)
                        Text("2")
                    }.padding(.horizontal)
                    Text("Enter your dates")
                }.padding(.horizontal)
                    .frame(width: UIScreen.main.bounds.width - 20, alignment: .leading)
                    .font(.headline)
                ZStack{
                    VStack{
                        Text("Departure").padding()
                        DatePicker(
                            "Date",
                            selection: $startDate,
                            displayedComponents: [.date]
                        ).padding(.horizontal)
                        DatePicker(
                            "Time",
                            selection: $startTime,
                            displayedComponents: [.hourAndMinute]
                        ).padding(.horizontal)
                        Text("Arrival").padding()
                        HStack{
                            Spacer()
                            DatePicker(
                                "Date",
                                selection: $endDate,
                                displayedComponents: [.date]
                            )
                            Spacer()
                        }.padding()
                    }
                }.background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    .padding()
                Button(action: {
                    if(inputAddressStart.contains(inputNameStart)){
                        inputNameStart = "Start Location"
                    }
                    if(inputAddressEnd.contains(inputNameEnd)){
                        inputNameEnd = "End Location"
                    }
                    

                    let trip = vm.createTrip(start_location: GeneralLocation(address: inputAddressStart, name: inputNameStart, latitude: startLatitude, longitude: startLongitude), end_location: GeneralLocation(address: inputAddressEnd, name: inputNameEnd, latitude: endLatitude, longitude: endLongitude), start_date: ItineraryPlanningView.dateToString(date: startDate), end_date: ItineraryPlanningView.dateToString(date: endDate), stops: [], start_time: ItineraryPlanningView.timeToString(date: startTime))
                    vm.addTripToUser(trip: trip)
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
                    editTrip = true
                }) {
                    Text("Continue").font(.headline)
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(15)
                        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 50)
                .navigationDestination(isPresented: $editTrip, destination: {TripView(vm: vm, trip: vm.current_trip)})
                
                Spacer()
                
            }
        }
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
                                VStack(alignment: .leading) {
                                    Text(location.title)
                                        .foregroundColor(Color.black)
                                    Text(location.subtitle)
                                        .font(.caption)
                                        .foregroundColor(Color.gray)
                                }
                                .padding(.vertical, 5)
                                .padding(.horizontal)
                            }
                            Divider()
                        }
                    }
                }
            }
            .frame(height: 120)
            .background(Color.white)
            .shadow(radius: 5)
            .padding(.horizontal, 10)
        }
    }
    
    static func dateToString(date: Date) -> String {
        dateformatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        return dateformatter.string(from: date)
    }
    
    static func timeToString(date: Date) -> String {
        dateformatter.dateFormat = "HH:mm a"
        return dateformatter.string(from: date)
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
                    
                    mapSearch.searchTerm = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName) \(reversedGeoLocation.city) \(reversedGeoLocation.state) \(reversedGeoLocation.zipCode)"
                    
                    inputAddress.wrappedValue = mapSearch.searchTerm
                    
                }
            }
        }
    }
}

#Preview {
    ItineraryPlanningView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"), start_date: "10-07-2024 22:42:59", end_date: "10-07-2024 22:42:59", stops: [], start_time: "10:45 PM")])), mapSearch: .init())
}
