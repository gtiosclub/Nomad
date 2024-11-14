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
    @State private var isPrivate: Bool = true
    @Environment(\.dismiss) var dismiss
    @ObservedObject var trip: Trip
    @State var routePlanned: Bool = false
    @State var backToEdit: Bool = false
    var letBack: Bool = true
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("Preview Your Route")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .padding(.top)
                    
                    RoutePreviewView(vm: vm, trip: Binding.constant(trip), currentStopLocation: Binding.constant(nil))
                        .frame(height: 300)
                    
                    Spacer().frame(height: 20)
                    
                    HStack {
                        Text(formatTimeDuration(duration: trip.route?.route?.expectedTravelTime ?? TimeInterval(0)))
                            .padding()
                            .fontWeight(.bold)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                        Text(formatDistance(distance: trip.route?.totalDistance() ?? 0))
                            .padding()
                            .fontWeight(.bold)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    
                    Text("Route Details")
                        .font(.headline)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                        .padding(.top)
                    
                    
                    if vm.current_trip != nil {
                        EnhancedRoutePlanListView(vm: vm)
                            .padding()
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(Text("No Route Details Available").foregroundColor(.gray))
                            .padding()
                    }
                    
                    VStack {
                        if !isCommunityTrip {
                            VStack(alignment: .leading) {
                                Text("Finalize Your Route")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)
                                
                                Text("Route Name")
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.top, 10)
                                    .padding(.leading)
                                
                                TextField("Trip Title", text: $tripTitle)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding()
                                
                                Text("Route Visibility")
                                    .font(.body)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.leading)
                                
                                
                                VStack(alignment: .leading) {
                                    RadioButton(text: "Public", isSelected: $isPrivate, value: false)
                                    RadioButton(text: "Private", isSelected: $isPrivate, value: true)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 30)
                            }
                            
                            HStack {
                                Button {
                                    backToEdit = true
                                } label: {
                                    Text("Edit Route")
                                        .padding()
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(8)
                                        .foregroundColor(Color.black)
                                }
                                .navigationDestination(isPresented: $backToEdit, destination: {
                                    ItineraryParentView(vm: vm, cvm: ChatViewModel())
                                })
                                
                                Spacer().frame(width: 60)
                                
                                Button("Save Route") {
                                    vm.setTripTitle(newTitle: $tripTitle.wrappedValue)
                                    vm.setIsPrivate(isPrivate: $isPrivate.wrappedValue)
                                    
                                    dismiss()
                                }
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .foregroundColor(.black)
                                .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        } else {
                            Button("Copy to My Trips") {
                                Task {
                                    await vm.createTrip(
                                        start_location: trip.getStartLocation(),
                                        end_location: trip.getEndLocation(),
                                        start_date: trip.getStartDate() ?? "",
                                        end_date: trip.getEndDate() ?? "",
                                        stops: trip.getStops()
                                    )
                                }
                                dismiss()
                            }
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(8)
                            .foregroundColor(.black)
                            .padding(.horizontal)
                        }
                        Button("Start Route") {
                            vm.startTrip(trip: trip)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.black)
                        .cornerRadius(8)
                        
                    }
                }
            }
            .onAppear {
                vm.setCurrentTrip(trip: trip)
                tripTitle = vm.current_trip?.getName() ?? ""
                isPrivate = vm.current_trip?.isPrivate ?? true
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
