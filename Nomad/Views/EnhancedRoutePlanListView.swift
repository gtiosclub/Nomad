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
                createLocationView(location: startLocation, time: nil, isLast: false, isFirst: true)
            }
            
            if let stops = vm.current_trip?.getStops() {
                ForEach(stops.indices, id: \.self) { index in
                    let stop = stops[index]
                    let time = vm.times[safe: index]
                    createLocationView(location: stop, time: time, isLast: false, isFirst: false)
                }
            }
            
            if let endLocation = vm.current_trip?.getEndLocation() {
                createLocationView(location: endLocation, time: vm.times.last, isLast: true, isFirst: false)
            }
        }
        .padding(.horizontal, 25)
        .padding(.top, -30)
        .padding(.vertical, 15)
        .padding(.leading, 0)
        .padding(.trailing, 10)
        .frame(maxWidth: UIScreen.main.bounds.width - 40)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear {
            vm.populateLegInfo()
        }
    }
    
    private func createLocationView(location: any POI, time: Double?, isLast: Bool, isFirst: Bool) -> some View {
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
                            .fill(Color(red: 0.18, green: 0.55, blue: 0.54))
                            .frame(width: 1.5, height: 90)
                            .offset(y: 68)
                    }
                    RouteCircle().padding(.top, 0)
                        .offset(y: 18)
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                // Drive Time
                if let time = time {
                    Text("\(time, specifier: "%.0f") MIN DRIVE")
                        .font(.caption)
                        .foregroundColor(.black)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .bold()
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                    }
                    
                    // Location details
                    VStack(alignment: .leading, spacing: 0) {
                        Text(location.getName())
                            .font(.headline)
                            .foregroundColor(.black)
                        
                        if let cuisine = (location as? Restaurant)?.getCuisine() {
                            Text("\(cuisine) Cuisine")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: 5) {
                            if let city = location.getCity() {
                                Text("\(city) ")
                            }
                            
                            if let ratable = location as? Ratable {
                                showRating(location: location, ratable: ratable)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                }
                .padding(.top, isFirst ? 30 : 0)
            }
            Spacer()
        }
    }
    
    private func showRating(location: any POI, ratable: Ratable) -> some View {
        HStack {
            if (location.getCity()) != nil {
                Text("•")
            }
            Text(" \(String(format: "%.2f", ratable.getRating()))")
            Image(systemName: "star")
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundColor(.secondary)
                .padding(.leading, -5)
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
