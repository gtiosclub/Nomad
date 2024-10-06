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
        .padding(.trailing, 40)
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
        HStack(alignment: .center, spacing: 5) {
            VStack(spacing: 0) {
                RouteCircle()
                if !isLast {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1, height: 50)
                        .padding(.leading, 0)
                }
            }
            .padding(.leading, 15)
            
            VStack {
                if let time = time {
                    Text("\(time, specifier: "%.0f") MIN")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(width: 50, alignment: .trailing)
                        .padding(.bottom, 15)
                }
                
                VStack {
                    Text(location.getName())
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding(.leading, 5)
                        .frame(alignment: .leading)
                    
                    HStack {
                        if location is Restaurant {
                            if let restaurantLocation = location as? Restaurant {
                                Text(restaurantLocation.getCuisine())
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        if location is Ratable {
                            if let ratableLocation = location as? Ratable {
                                Text(ratableLocation.getRating().description)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 0)
    }
}

#Preview {
    let trip = Trip(
        start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech"),
        end_location: Hotel(address: "387 West Peachtree", name: "Hilton"),
        stops: [Restaurant(address: "85 5th St. NW Atlanta, GA 30308", name: "Moes", rating: 4.0, cuisine: "Mexican"), GeneralLocation(address: "630 10th St NW, Atlanta, GA 30318", name: "QuikTrip")]
    )

    let user = User(id: "89379", name: "Austin", trips: [trip])
    var vm = UserViewModel(user: user)
    vm.current_trip = trip

    return EnhancedRoutePlanListView(vm: vm)
}
