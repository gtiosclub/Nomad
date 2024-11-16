//
//  PreviewRouteView.swift
//  Nomad
//
//  Created by amber verma on 10/8/24.
//

import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct PreviewRouteView: View {
    @ObservedObject var vm: UserViewModel
    @State private var tripTitle: String = ""
    @State private var privacy: String = "Private"
    @Environment(\.dismiss) var dismiss
    @ObservedObject var trip: Trip
    @State var routePlanned: Bool = false
    @State var backToEdit: Bool = false
    var letBack: Bool = true
    var privacyTypes = ["Private", "Public"]
    @State var navigateToCopiedTrip: Bool = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    RoutePreviewView(vm: vm, cvm: ChatViewModel(), trip: Binding.constant(trip), currentStopLocation: Binding.constant(nil))
                        .frame(height: 300)
                    
                    Spacer().frame(height: 20)
                    
                    HStack {
                        Text("Preview")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading)
                        
                        Spacer()
                        
                        if !isCommunityTrip {
                            Button {
                                var successful: Bool = false
                                Task {
                                    successful = await vm.deleteTrip()
                                    
                                    if successful {
                                        dismiss()
                                    }
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(Color.red)
                                    .font(.system(size: 20))
                            }
                            
                            Button {
                                vm.setTripTitle(newTitle: $tripTitle.wrappedValue)
                                vm.setIsPrivate(isPrivate: $privacy.wrappedValue == "Private")
                                backToEdit = true
                            } label: {
                                Image(systemName: "square.and.pencil")
                                    .foregroundStyle(Color.nomadDarkBlue)
                                    .font(.system(size: 20))
                            }
                            .navigationDestination(isPresented: $backToEdit, destination: {
                                ItineraryParentView(vm: vm, cvm: ChatViewModel())
                            })
                            .padding(.trailing, 20)
                            .padding(.leading, 10)
                        }
                    }
                        
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Time")
                                .padding(.top, 0)
                                .font(.system(size: 14))
                                .foregroundStyle(.black)
                            
                            Text(formatTimeDuration(duration: trip.route?.route?.expectedTravelTime ?? TimeInterval(0)))
                                .padding(.bottom, 0)
                                .font(.system(size: 22))
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Text("Start")
                                .padding(.top, 0)
                                .font(.system(size: 14))
                                .foregroundStyle(.black)
                            
                            HStack {
                                Text("\(convertDateToShortFormat(trip.getStartDate())),")
                                    .padding(.bottom, 0)
                                    .font(.system(size: 22))
                                    .foregroundStyle(.black)
                                
                                Text(trip.getStartTime())
                                    .padding(.bottom, 0)
                                    .font(.system(size: 22))
                                    .foregroundStyle(.black)
                            }
                        }
                        .padding(.trailing, 10)
                        
                        Spacer()
                        
                        VStack(alignment: .leading) {
                            Text("Distance")
                                .padding(.top, 0)
                                .font(.system(size: 14))
                                .foregroundStyle(.black)
                            
                            Text(formatDistance(distance: trip.route?.totalDistance() ?? 0))
                                .padding(.bottom, 0)
                                .font(.system(size: 22))
                                .foregroundStyle(.black)
                            
                            Spacer()
                            
                            Text("End")
                                .padding(.top, 0)
                                .font(.system(size: 14))
                                .foregroundStyle(.black)
                            
                            Text(convertDateToShortFormat(trip.getEndDate()))
                                .padding(.bottom, 0)
                                .font(.system(size: 22))
                                .foregroundStyle(.black)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
                    .onChange(of: vm.times) {}
                    .frame(alignment: .leading)
                    
                    Text("Route Details")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .padding(.top)
                    
                    
                    if vm.current_trip != nil {
                        EnhancedRoutePlanListView(vm: vm)
                            .padding(.top, 0)
                            .padding(.horizontal)
                            .padding(.bottom, 30)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(Text("No Route Details Available").foregroundColor(.gray))
                            .padding()
                    }
                    
                    VStack {
                        if !isCommunityTrip {
                            Text("Finalize Your Trip")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading)
                            
                            VStack(alignment: .leading) {
                                Text("Name")
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 6)
                                    .padding(.leading)
                                    .padding(.bottom, 0)
                                
                                TextField("Trip Title", text: $tripTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.horizontal, 20)
                                    .padding(.bottom)
                                
                                Text("Community Visibility")
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)
                                
                                VStack {
                                    Picker("Private", selection: $privacy) {
                                        ForEach(privacyTypes, id: \.self) { type in
                                            Text(type)
                                        }
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal, 20)
                            }
                            .padding(.horizontal)
                            
                            HStack {
                                Spacer()
                                
//                                Button {
//                                    backToEdit = true
//                                } label: {
//                                    Button("Edit") {
//                                        backToEdit = true
//                                    }
//                                    .padding()
//                                    .padding(.horizontal, 15)
//                                    .background(Color.gray.opacity(0.2))
//                                    .foregroundColor(.black)
//                                    .cornerRadius(8)
//                                    .shadow(radius: 5)
//                                }
//                                .navigationDestination(isPresented: $backToEdit, destination: {
//                                    ItineraryParentView(vm: vm, cvm: ChatViewModel())
//                                })
//                                
//                                Spacer(minLength: 20)
                                                                
                                Button("Start") {
                                    vm.setTripTitle(newTitle: $tripTitle.wrappedValue)
                                    vm.setIsPrivate(isPrivate: $privacy.wrappedValue == "Private")
                                    
                                    var successful: Bool = false
                                    Task {
                                        if !letBack {
                                            successful = await vm.addTripToFirebase()
                                        } else {
                                            successful = await vm.modifyTripInFirebase()
                                        }
                                        
                                        if successful {
                                            vm.startTrip(trip: trip)
                                        }
                                    }
                                }
                                .padding()
                                .padding(.horizontal, 30)
                                .background(Color.nomadLightBlue)
                                .foregroundColor(.black)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.5), radius: 5, y: 3)
                                
                                Spacer(minLength: 20)
                                                                
                                Button("Save") {
                                    vm.setTripTitle(newTitle: $tripTitle.wrappedValue)
                                    vm.setIsPrivate(isPrivate: $privacy.wrappedValue == "Private")
                                    
                                    var successful: Bool = false
                                    Task {
                                        if !letBack {
                                            successful = await vm.addTripToFirebase()
                                        } else {
                                            successful = await vm.modifyTripInFirebase()
                                        }
                                        
                                        if successful {
                                            dismiss()
                                        }
                                    }
                                }
                                .padding()
                                .padding(.horizontal, 30)
                                .background(Color.nomadDarkBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.5), radius: 5, y: 3)
                                
                                Spacer()
                            }
                            .padding()
                            .padding(.top, 20)
                        } else {
                            Button("Copy to My Trips") {
                                Task {
                                    await vm.createTrip (
                                        start_location: trip.getStartLocation(),
                                        end_location: trip.getEndLocation(),
                                        start_date: trip.getStartDate(),
                                        end_date: trip.getEndDate(),
                                        stops: trip.getStops(),
                                        start_time: trip.getStartTime(),
                                        coverImageURL: trip.getCoverImageURL()
                                    )
                                    
                                    navigateToCopiedTrip = true
                                }
                            }
                            .padding()
                            .background(Color.nomadDarkBlue)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                            .navigationDestination(isPresented: $navigateToCopiedTrip, destination: {
                                if let trip = vm.current_trip {
                                    PreviewRouteView(vm: vm, trip: trip, letBack: false)
                                }
                            })
                        }
                    }
                }
            }
            .onAppear {
                vm.setCurrentTrip(trip: trip)
                tripTitle = vm.current_trip?.getName() ?? ""
                privacy = (vm.current_trip?.isPrivate ?? true) ? "Private" : "Public"
                if let route = trip.route {
                    vm.populateLegInfo()
                    routePlanned = true
                } else {
                    Task {
                        await updateTripRoute()
                        vm.populateLegInfo()
                        routePlanned = true
                    }
                }
            }
            .navigationBarBackButtonHidden(!letBack)
            .toolbar(letBack ? .visible : .hidden, for: .navigationBar)
        }
    }
    
    func convertDateToShortFormat(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM-dd-yyyy"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM. d"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return "" // Return nil if the date string is invalid
        }
    }
        
    func updateTripRoute() async {
        let start_loc = trip.getStartLocation()
        let end_loc = trip.getEndLocation()
        let all_stops = trip.getStops()
        
        var all_pois: [any POI] = []
        all_pois.append(start_loc)
        all_pois.append(contentsOf: all_stops)
        all_pois.append(end_loc)
        
        if let newRoutes = await MapManager.manager.generateRoute(pois: all_pois) {
            print("setting new route")
            trip.route = newRoutes[0]
//            vm.updateTrip(trip: trip)
        }
    }
    
    // duration is in seconds
    func formatTimeDuration(duration: TimeInterval) -> String {
        let minsLeft = Int(duration.truncatingRemainder(dividingBy: 3600))
        return "\(Int(duration / 3600)) hr \(Int(minsLeft / 60)) min"
    }
    
    func formatDistance(distance: Double) -> String {
        return String(format: "%.0f miles", distance)
    }
    
    private var isCommunityTrip: Bool {
        return vm.community_trips.contains(where: { $0.id == trip.id })
    }
    
    struct RadioButton: View {
        var text: String
        @Binding var isSelected: Bool
        var value: Bool
        
        var body: some View {
            Button(action: {
                isSelected = value
            }) {
                HStack {
                    ZStack {
                        Circle()
                            .stroke(Color.gray, lineWidth: 2)
                            .frame(width: 10, height: 10)
                        
                        if isSelected == value {
                            Circle()
                                .fill(Color.gray)
                                .frame(width: 12, height: 12)
                        }
                    }
                    Text(text)
                        .foregroundColor(.black)
                }
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    PreviewRouteView(vm: .init(user: User(id: "sampleUserID", name: "Sample User", trips: [
        Trip(start_location: Restaurant(address: "848 Spring Street Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090),
             end_location: Hotel(address: "201 8th Ave S Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947),
             start_date: "10-05-2024", end_date: "10-05-2024", stops: [])
    ])), trip: Trip(start_location: Restaurant(address: "848 Spring Street Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090),
                    end_location: Hotel(address: "201 8th Ave S Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947),
                    start_date: "10-05-2024", end_date: "10-05-2024", stops: []))
}
