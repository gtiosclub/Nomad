//
//  EnhancedRoutePlanListView.swift
//  Nomad
//
//  Created by Austin Huguenard on 10/6/24.
//

import SwiftUI

struct EnhancedRoutePlanListView: View {
    @ObservedObject var vm: UserViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if let startLocation = vm.current_trip?.getStartLocation() {
                createLocationView(location: startLocation, time: nil, isLast: false)
            }
            
            if let stops = vm.current_trip?.getStops() {
                ForEach(stops.indices, id: \.self) { index in
                    let stop = stops[index]
                    let time = vm.times[safe: index]
                    createLocationView(location: stop, time: time, isLast: false)
                }
            }
            
            if let endLocation = vm.current_trip?.getEndLocation() {
                createLocationView(location: endLocation, time: vm.times.last, isLast: true)
            }
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 15)
        .padding(.leading, 0)
        .padding(.trailing, 10)
        .frame(maxWidth: UIScreen.main.bounds.width - 40)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear {
            Task {
                await vm.calculateLegInfo()
            }
        }
    }
    
    private func createLocationView(location: any POI, time: Double?, isLast: Bool) -> some View {
        HStack(alignment: .center, spacing: 10) {
            // Left part: Circle + Vertical line
            /*
             VStack(spacing: 0) {
             RouteCircle()
             if !isLast {
             Rectangle()
             .fill(Color.gray.opacity(0.5))
             .frame(width: 2, height: 120)
             }
             
             }
             .padding(.top, 0)
             */
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    if !isLast {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 2, height: 90)
                            .offset(y: 50)
                    }
                    RouteCircle().padding(.top, 0)
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                // Drive Time
                if let time = time {
                    Text("\(time, specifier: "%.0f") MIN DRIVE")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                }
                
                // Stop Info
                HStack(alignment: .center, spacing: 10) {
                    // Placeholder for location image
                    if let imagable = location as? Imagable, let imageurl = imagable.getImageUrl() {
                        AsyncImage(url: URL(string: imageurl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 60)
                                .cornerRadius(10)
                                .padding(.horizontal, 10)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 60)
                                .cornerRadius(10)
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 60)
                            .cornerRadius(10)
                    }
                    
                    // Location details
                    VStack(alignment: .leading, spacing: 0) {
                        Text(location.getName())
                            .font(.headline)
                            .foregroundColor(.black)
                            .padding(.bottom, 5)
                        
                        if let cuisine = (location as? Restaurant)?.getCuisine() {
                            Text("\(cuisine) Cuisine")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 5) {
                            if let city = location.getCity() {
                                Text("\(city) ")
                            }
                            
                            if let ratable = location as? Ratable {
                                Text("• \(String(format: "%.2f", ratable.getRating()))")
                                Image(systemName: "star")
                                    .resizable()
                                    .frame(width: 14, height: 14)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        if let open_time = (location as? Restaurant)?.getOpenTime() {
                            if let close_time = (location as? Restaurant)?.getCloseTime() {
                                Text("Open • \(open_time) - \(close_time)")
                            }
                        }
                        
                    }
                }
            }
            Spacer()
        }
    }
}


#Preview {
    let trip = Trip(
        start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech", latitude: 0.0, longitude: 0.0),
        end_location: Hotel(address: "387 West Peachtree", name: "Hilton", latitude: 0.0, longitude: 0.0),
        stops: [Restaurant(address: "85 5th St. NW Atlanta, GA 30308", name: "Moes", rating: 4.0, cuisine: "Mexican", latitude: 0.0, longitude: 0.0), GeneralLocation(address: "630 10th St NW, Atlanta, GA 30318", name: "QuikTrip", latitude: 0.0, longitude: 0.0)]
    )

    let user = User(id: "89379", name: "Austin", trips: [trip])
    var vm = UserViewModel(user: user)
    vm.current_trip = trip

    return EnhancedRoutePlanListView(vm: vm)
}
