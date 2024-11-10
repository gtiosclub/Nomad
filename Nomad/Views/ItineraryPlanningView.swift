////
////  ItineraryPlanningView.swift
////  Nomad
////
////  Created by Nicholas Candello on 9/15/24.
////
//
//import SwiftUI
//import CoreLocation
//import MapKit
//
//struct ItineraryPlanningView: View {
//    @State var inputAddressStart: String = ""
//    @State var inputAddressEnd: String = ""
//    @State var inputNameStart: String = ""
//    @State var inputNameEnd: String = ""
//    @State var startLatitude: Double = 0
//    @State var startLongitude: Double = 0
//    @State var endLatitude: Double = 0
//    @State var endLongitude: Double = 0
//    @State var editTripAtlas: Bool = false
//    @State var editTripContinue: Bool = false
//    @State var startDate: Date = Date()
//    @State var endDate: Date = Date()
//    @State var startTime: Date = Date()
//    @State private static var dateformatter = DateFormatter()
//    @ObservedObject var vm: UserViewModel
//    @ObservedObject var aiVM: AIAssistantViewModel = AIAssistantViewModel()
//    @ObservedObject var mapSearch = MapSearch()
//    @State var isClicked: Bool = false
//    @State var startAddressError: String = ""
//    @State var endAddressError: String = ""
//    @State var isLoading: Bool = false
//    @State var bothAddressError: String = ""
//    
//    enum completion{
//        case null, start, end
//    }
//    
//    @State var lastEdited: completion = .null
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Section(content: {
//                    Text("Let's plan your new trip")
//                        .frame(width: UIScreen.main.bounds.width - 20, alignment: .leading)
//                        .font(.headline)
//                }).padding()
//                HStack{
//                    VStack{
//                        ZStack{
//                            Circle()
//                                .fill(Color.white)
//                                .frame(width: 24, height: 24)
//                                .overlay {
//                                    Circle()
//                                        .stroke(Color.gray, lineWidth: 1)
//                                }
//                            
//                            Text("1")
//                                .font(.system(size: 16))
//                                .foregroundColor(.gray)
//                        }
//                        Spacer()
//                    }
//                    VStack{
//                        HStack{
//                            Text("Enter your route information").frame(alignment: .leading).padding(.horizontal)
//                            Spacer()
//                        }
//                        ZStack {
//                            VStack(spacing: 15){
//                                if !bothAddressError.isEmpty {
//                                    Text(bothAddressError)
//                                        .foregroundColor(.red)
//                                        .font(.caption)
//                                        .padding()
//                                }
//                                    VStack{
//                                        TextField("Start Location", text: $inputAddressStart).padding().background(Color.white).cornerRadius(10)
//                                            .onChange(of: inputAddressStart) {
//                                                if !startAddressError.isEmpty {
//                                                    startAddressError = ""
//                                                }
//                                                lastEdited = .start
//                                                mapSearch.searchTerm = inputAddressStart
//                                                
//                                                
//                                            }
//                                        if (!startAddressError.isEmpty) {
//                                            Text(startAddressError)
//                                                .foregroundColor(.red)
//                                                .font(.caption)
//                                        }
//                                        
//                                        }
//                                    
//                                
//                                ZStack{
//                                    VStack {
//                                        TextField("End Location", text: $inputAddressEnd).padding().background(Color.white).cornerRadius(10)
//                                            .onChange(of: inputAddressEnd) {
//                                                if !endAddressError.isEmpty {
//                                                    endAddressError = ""
//                                                }
//                                                lastEdited = .end
//                                                mapSearch.searchTerm = inputAddressEnd
//                                                
//                                                
//                                            }
//                                        if (!endAddressError.isEmpty) {
//                                            Text(endAddressError)
//                                                .foregroundColor(.red)
//                                                .font(.caption)
//                                            }
//                                    }
//                                    
//                                
//                                    if(lastEdited == completion.start && !isClicked){
//                                        dropdownMenu(inputAddress: $inputAddressStart, inputName: $inputNameStart, inputLatitude: $startLatitude, inputLongitude: $startLongitude)
//                                    }
//                                    
//                                }
//                                if(lastEdited == completion.end && !isClicked){
//                                    dropdownMenu(inputAddress: $inputAddressEnd, inputName: $inputNameEnd, inputLatitude: $endLatitude, inputLongitude: $endLongitude)
//                                }
//                            }.padding(20)

//                        }.background(Color.gray.opacity(0.3))
//                            .cornerRadius(15)
//                            .padding()
//                    }
//                }.padding(.horizontal)
//                    .frame(width: UIScreen.main.bounds.width - 20, height: 230, alignment: .leading)
//                    .font(.headline)
//                
//                HStack{
//                    VStack{
//                        ZStack{
//                            Circle()
//                                .fill(Color.white)
//                                .frame(width: 24, height: 24)
//                                .overlay {
//                                    Circle()
//                                        .stroke(Color.gray, lineWidth: 1)
//                                }
//                            
//                            Text("2")
//                                .font(.system(size: 16))
//                                .foregroundColor(.gray)
//                        }
//                        Spacer()
//                    }
//                    VStack{
//                        HStack{
//                            Text("Enter your dates").frame(alignment: .leading).padding(.horizontal)
//                            Spacer()
//                        }
//                        ZStack{
//                            VStack{
//                                Text("Departure").padding()
//                                HStack{
//                                    DatePicker(
//                                        "",
//                                        selection: $startDate,
//                                        displayedComponents: [.date]
//                                    )
//                                    .onChange(of: startDate) { oldValue, newValue in
//                                        if startDate > endDate {
//                                            endDate = startDate
//                                        }
//                                    }
//                                    DatePicker(
//                                        "",
//                                        selection: $startTime,
//                                        displayedComponents: [.hourAndMinute]
//                                    )
//                                }.padding(.horizontal)
//                                
//                                Text("Arrival").padding()
//                                HStack{
//                                    DatePicker(
//                                        "",
//                                        selection: $endDate,
//                                        displayedComponents: [.date]
//                                    )
//                                    Spacer(minLength: 60)
//                                }.padding()
//                            }
//                        }.background(Color.gray.opacity(0.3))
//                            .cornerRadius(15)
//                            .padding()
//                    }
//                }.padding(.horizontal)
//                    .frame(width: UIScreen.main.bounds.width - 20, height: 300, alignment: .leading)
//                    .font(.headline)
//               
//                Button(action: {
//                    
//                    //reset error states
//                    startAddressError = ""
//                    endAddressError = ""
//                    bothAddressError = ""
//                    
//                    //check if start and end location are valid address that contains at least two commas
//                    if inputAddressStart.components(separatedBy: ",").count < 3 && inputAddressEnd.components(separatedBy: ",").count < 3 {
//                        bothAddressError = "Both addresses need to be entered with a street, city, and state."
//                    } else if inputAddressStart.components(separatedBy: ",").count < 3 {
//                            startAddressError = "Please enter a valid start location with a street, city, and state."
//                    } else if inputAddressEnd.components(separatedBy: ",").count < 3 {
//                            endAddressError = "Please enter a valid end location with a street, city, and state."
//                        }
//                    
//                    
//                    if(inputAddressStart.contains(inputNameStart)){
//                        inputNameStart = "Start Location"
//                    }
//                    if(inputAddressEnd.contains(inputNameEnd)){
//                        inputNameEnd = "End Location"
//                    }
//                    
//                    if (startAddressError.isEmpty && endAddressError.isEmpty && bothAddressError.isEmpty) {
//                        Task {
//                            await vm.createTrip(start_location: GeneralLocation(address: inputAddressStart, name: inputNameStart, latitude: startLatitude, longitude: startLongitude), end_location: GeneralLocation(address: inputAddressEnd, name: inputNameEnd, latitude: endLatitude, longitude: endLongitude), start_date: ItineraryPlanningView.dateToString(date: startDate), end_date: ItineraryPlanningView.dateToString(date: endDate), stops: [], start_time: ItineraryPlanningView.timeToString(date: startTime))
//                            
//                            inputNameEnd = ""
//                            inputNameStart = ""
//                            inputAddressEnd = ""
//                            inputAddressStart = ""
//                            startDate = Date()
//                            endDate = Date()
//                            startTime = Date()
//                            startLatitude = 0.0
//                            startLongitude = 0.0
//                            endLatitude = 0.0
//                            endLongitude = 0.0
//                            editTripAtlas = true
//                            
//                            
//                        }
//
//
//                    }) {
//                        Label("Generate with Atlas", systemImage: "wand.and.sparkles").font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .background(
//                                LinearGradient(
//                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
//                                    startPoint: .leading,
//                                    endPoint: .trailing
//                                )
//                            )
//
//                            .cornerRadius(15)
//                            .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
//                    }
//                    .navigationDestination(isPresented: $editTripAtlas, destination: {
//                        ItineraryParentView(vm: vm, cvm: ChatViewModel())
//                    })
////                    
//                    Button(action: {
//                        
//                        //reset error states
//                       startAddressError = ""
//                    endAddressError = ""
//                    bothAddressError = ""
//                    
//                    //check if start and end location are valid address that contains at least two commas
//                    if inputAddressStart.components(separatedBy: ",").count < 3 && inputAddressEnd.components(separatedBy: ",").count < 3 {
//                        bothAddressError = "Both addresses need to be entered with a street, city, and state."
//                    } else if inputAddressStart.components(separatedBy: ",").count < 3 {
//                            startAddressError = "Please enter a valid start location with a street, city, and state."
//                    } else if inputAddressEnd.components(separatedBy: ",").count < 3 {
//                            endAddressError = "Please enter a valid end location with a street, city, and state."
//                        }
//                    
//                    
//                    if(inputAddressStart.contains(inputNameStart)){
//                        inputNameStart = "Start Location"
//                    }
//                    if(inputAddressEnd.contains(inputNameEnd)){
//                        inputNameEnd = "End Location"
//                    }
//                    
//                    if (startAddressError.isEmpty && endAddressError.isEmpty && bothAddressError.isEmpty) {
//                        Task {
//                            await vm.createTrip(start_location: GeneralLocation(address: inputAddressStart, name: inputNameStart, latitude: startLatitude, longitude: startLongitude), end_location: GeneralLocation(address: inputAddressEnd, name: inputNameEnd, latitude: endLatitude, longitude: endLongitude), start_date: ItineraryPlanningView.dateToString(date: startDate), end_date: ItineraryPlanningView.dateToString(date: endDate), stops: [], start_time: ItineraryPlanningView.timeToString(date: startTime))
//                            
//                            inputNameEnd = ""
//                            inputNameStart = ""
//                            inputAddressEnd = ""
//                            inputAddressStart = ""
//                            startDate = Date()
//                            endDate = Date()
//                            startTime = Date()
//                            startLatitude = 0.0
//                            startLongitude = 0.0
//                            endLatitude = 0.0
//                            endLongitude = 0.0
//                            editTripContinue = true
//                            
//                          
//                        }
//
//                    }) {
//                        Text("Continue").font(.headline)
//                            .foregroundColor(.black)
//                            .padding()
//                            .background(Color.gray.opacity(0.3))
//                            .cornerRadius(15)
//                            .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
//                    }
//                    .navigationDestination(isPresented: $editTripContinue, destination: {
//                        ItineraryParentView(vm: vm, cvm: ChatViewModel())
//                    })
//                }
//                
//            
//                                
//                Spacer()
//                
//            }.overlay(
//                Group {
//                    if isLoading {
//                        AtlasLoadingView()
//                            .frame(width: 80, height: 80) // Adjust size if needed
//                    }
//                }
//            )
//        }
//        .onAppear() {
//            vm.clearCurrentTrip()
//        }
//    }
//    
//    @ViewBuilder
//    func dropdownMenu(inputAddress: Binding<String>, inputName: Binding<String>, inputLatitude: Binding<Double>, inputLongitude: Binding<Double>) -> some View {
//        if(!mapSearch.locationResults.isEmpty){
//            VStack(spacing: 0) {
//                ScrollView {
//                    VStack(spacing: 0) {
//                        ForEach(mapSearch.locationResults, id: \.self) { location in
//                            Button {
//                                reverseGeo(location: location, inputAddress: inputAddress, inputLatitude: inputLatitude, inputLongitude: inputLongitude)
//                                inputName.wrappedValue = location.title
//                                isClicked = true
//                                lastEdited = .null
//                                mapSearch.locationResults.removeAll()
//                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
//                                    mapSearch.locationResults.removeAll()
//                                    isClicked = false
//                                }
//                                
//                            } label: {
//                                HStack {
//                                    VStack(alignment: .leading) {
//                                        Text(location.title)
//                                            .foregroundColor(Color.black)
//                                        Text(location.subtitle)
//                                            .font(.caption)
//                                            .foregroundColor(Color.gray)
//                                            .multilineTextAlignment(.leading)
//                                    }
//                                    .padding(.vertical, 5)
//                                    .padding(.horizontal)
//                                    Spacer()
//                                }
//                            }
//                            Divider()
//                        }
//                    }
//                }
//            }
//            .frame(height: 120)
//            .background(Color.white)
//            .shadow(radius: 5)
//            .padding(.horizontal, 10)
//        }
//    }
//    
//    static func dateToString(date: Date) -> String {
//        dateformatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
//        return dateformatter.string(from: date)
//    }
//    
//    static func timeToString(date: Date) -> String {
//        dateformatter.dateFormat = "HH:mm a"
//        return dateformatter.string(from: date)
//    }
//    func reverseGeo(location: MKLocalSearchCompletion, inputAddress: Binding<String>, inputLatitude: Binding<Double>, inputLongitude: Binding<Double>) {
//        let searchRequest = MKLocalSearch.Request(completion: location)
//        let search = MKLocalSearch(request: searchRequest)
//        var coordinateK : CLLocationCoordinate2D?
//        search.start { (response, error) in
//            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
//                coordinateK = coordinate
//            }
//            
//            if let c = coordinateK {
//                let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
//                
//                inputLatitude.wrappedValue = c.latitude
//                inputLongitude.wrappedValue = c.longitude
//                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
//                    
//                    guard let placemark = placemarks?.first else {
//                        let errorString = error?.localizedDescription ?? "Unexpected Error"
//                        print("Unable to reverse geocode the given location. Error: \(errorString)")
//                        return
//                    }
//                    
//                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)
//                    
//                    mapSearch.searchTerm = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName), \(reversedGeoLocation.city), \(reversedGeoLocation.state) \(reversedGeoLocation.zipCode)"
//                    
//                    inputAddress.wrappedValue = mapSearch.searchTerm
//                    
//                }
//            }
//        }
//    }
//}
//
//#Preview {
//    ItineraryPlanningView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech", latitude: 33.771712, longitude: -84.392842), end_location: Hotel(address: "387 West Peachtree, Atlanta, GA", name: "Hilton", latitude: 33.763814, longitude: -84.387338))])))
//}

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
    @ObservedObject var aiVM: AIAssistantViewModel = AIAssistantViewModel()
    @ObservedObject var mapSearch = MapSearch()
    @State var isClicked: Bool = false
    @State var startAddressError: String = ""
    @State var endAddressError: String = ""
    @State var isLoading: Bool = false
    @State var bothAddressError: String = ""
    
    enum completion {
        case null, start, end
    }
    
    @State var lastEdited: completion = .null
    
    var body: some View {
        NavigationStack {
            VStack {
                Section {
                    Text("Let's plan your new trip")
                        .frame(width: UIScreen.main.bounds.width - 20, alignment: .leading)
                        .font(.headline)
                }.padding()
                
                HStack {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 24, height: 24)
                                .overlay {
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                            
                            Text("1")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    
                    VStack {
                        HStack {
                            Text("Enter your route information")
                                .frame(alignment: .leading)
                                .padding(.horizontal)
                            Spacer()
                        }
                        ZStack {
                            VStack(spacing: 15) {
                                if !bothAddressError.isEmpty {
                                    Text(bothAddressError)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                        .padding()
                                }
                                
                                VStack {
                                    TextField("Start Location", text: $inputAddressStart)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(10)
                                        .onChange(of: inputAddressStart) { _ in
                                            if !startAddressError.isEmpty {
                                                startAddressError = ""
                                            }
                                            lastEdited = .start
                                            mapSearch.searchTerm = inputAddressStart
                                        }
                                    
                                    if !startAddressError.isEmpty {
                                        Text(startAddressError)
                                            .foregroundColor(.red)
                                            .font(.caption)
                                    }
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
                                        
                                        if !endAddressError.isEmpty {
                                            Text(endAddressError)
                                                .foregroundColor(.red)
                                                .font(.caption)
                                        }
                                    }
                                    
                                    if lastEdited == completion.start && !isClicked {
                                        dropdownMenu(inputAddress: $inputAddressStart, inputName: $inputNameStart, inputLatitude: $startLatitude, inputLongitude: $startLongitude)
                                    }
                                }
                                
                                if lastEdited == completion.end && !isClicked {
                                    dropdownMenu(inputAddress: $inputAddressEnd, inputName: $inputNameEnd, inputLatitude: $endLatitude, inputLongitude: $endLongitude)
                                }
                            }.padding(20)
                        }.background(Color.gray.opacity(0.3))
                            .cornerRadius(15)
                            .padding()
                    }
                }.padding(.horizontal)
                    .frame(width: UIScreen.main.bounds.width - 20, height: 230, alignment: .leading)
                    .font(.headline)
                
                HStack {
                    VStack {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 24, height: 24)
                                .overlay {
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 1)
                                }
                            
                            Text("2")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    }
                    
                    VStack {
                        HStack {
                            Text("Enter your dates")
                                .frame(alignment: .leading)
                                .padding(.horizontal)
                            Spacer()
                        }
                        ZStack {
                            VStack {
                                Text("Departure").padding()
                                HStack {
                                    DatePicker("", selection: $startDate, displayedComponents: [.date])
                                        .onChange(of: startDate) { oldValue, newValue in
                                            if startDate > endDate {
                                                endDate = startDate
                                            }
                                        }
                                    
                                    DatePicker("", selection: $startTime, displayedComponents: [.hourAndMinute])
                                }.padding(.horizontal)
                                
                                Text("Arrival").padding()
                                HStack {
                                    DatePicker("", selection: $endDate, displayedComponents: [.date])
                                    Spacer(minLength: 60)
                                }.padding()
                            }
                        }.background(Color.gray.opacity(0.3))
                            .cornerRadius(15)
                            .padding()
                    }
                }.padding(.horizontal)
                    .frame(width: UIScreen.main.bounds.width - 20, height: 300, alignment: .leading)
                    .font(.headline)
                
                HStack {
                    Button(action: {
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
                        
                        if inputAddressStart.contains(inputNameStart) {
                            inputNameStart = "Start Location"
                        }
                        if inputAddressEnd.contains(inputNameEnd) {
                            inputNameEnd = "End Location"
                        }
                        
                        if startAddressError.isEmpty && endAddressError.isEmpty && bothAddressError.isEmpty {
                            Task {
                                isLoading = true
                                
                                await vm.createTrip(start_location: GeneralLocation(address: inputAddressStart, name: inputNameStart, latitude: startLatitude, longitude: startLongitude), end_location: GeneralLocation(address: inputAddressEnd, name: inputNameEnd, latitude: endLatitude, longitude: endLongitude), start_date: ItineraryPlanningView.dateToString(date: startDate), end_date: ItineraryPlanningView.dateToString(date: endDate), stops: [], start_time: ItineraryPlanningView.timeToString(date: startTime))
                                
                                await aiVM.generateTripWithAtlas(userVM: vm)
                                
                                await vm.updateRoute()
                                
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
                                editTripAtlas = true
                                
                                isLoading = false
                            }
                        }
                    }) {
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
                    .navigationDestination(isPresented: $editTripAtlas) {
                        ItineraryParentView(vm: vm, cvm: ChatViewModel())
                    }
                    
                    Button(action: {
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
                        
                        if inputAddressStart.contains(inputNameStart) {
                            inputNameStart = "Start Location"
                        }
                        if inputAddressEnd.contains(inputNameEnd) {
                            inputNameEnd = "End Location"
                        }
                        
                        if startAddressError.isEmpty && endAddressError.isEmpty && bothAddressError.isEmpty {
                            Task {
                                await vm.createTrip(start_location: GeneralLocation(address: inputAddressStart, name: inputNameStart, latitude: startLatitude, longitude: startLongitude), end_location: GeneralLocation(address: inputAddressEnd, name: inputNameEnd, latitude: endLatitude, longitude: endLongitude), start_date: ItineraryPlanningView.dateToString(date: startDate), end_date: ItineraryPlanningView.dateToString(date: endDate), stops: [], start_time: ItineraryPlanningView.timeToString(date: startTime))
                                
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
                                editTripContinue = true
                            }
                        }
                    }) {
                        Text("Continue").font(.headline)
                            .foregroundColor(.black)
                            .padding()
                            .background(Color.gray.opacity(0.3))
                            .cornerRadius(15)
                            .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .navigationDestination(isPresented: $editTripContinue) {
                        ItineraryParentView(vm: vm, cvm: ChatViewModel())
                    }
                    
                }
            }.overlay(
                Group {
                    if isLoading {
                        AtlasLoadingView()
                            .frame(width: 80, height: 80) // Adjust size if needed
                    }
                }
            )
        }.onAppear() {
            vm.clearCurrentTrip()
        }
    }
    
    static func dateToString(date: Date) -> String {
        dateformatter.dateFormat = "MM/dd/yyyy"
        return dateformatter.string(from: date)
    }
    
    static func timeToString(date: Date) -> String {
        dateformatter.dateFormat = "HH:mm"
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
                                            Text(location.subtitle)
                                                .font(.caption)
                                                .foregroundColor(Color.gray)
                                                .multilineTextAlignment(.leading)
                                        }
                                        .padding(.vertical, 5)
                                        .padding(.horizontal)
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
                .padding(.horizontal, 10)
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
