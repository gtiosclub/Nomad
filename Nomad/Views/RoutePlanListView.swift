//
//  RoutePlanListView.swift
//  Nomad
//
//  Created by Brayden Huguenard on 10/2/24.
//

import SwiftUI

struct RoutePlanListView: View {
    @ObservedObject var vm: UserViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            if let startLocation = vm.current_trip?.getStartLocation() {
                createLocationView(locationName: "Start at \(startLocation.name)", time: nil, isLast: false)
            }

            if let stops = vm.current_trip?.getStops() {
                ForEach(stops.indices, id: \.self) { index in
                    let stopName = stops[index].name
                    let time = vm.times[safe: index]
                    createLocationView(locationName: "Stop at \(stopName)", time: time, isLast: false)
                }
            }

            if let endLocation = vm.current_trip?.getEndLocation() {
                createLocationView(locationName: "End at \(endLocation.name)", time: vm.times.last, isLast: true)
            }
        }
        .padding(.horizontal, 25)
        .padding(.vertical, 25)
        .padding(.leading, 0)
        .padding(.trailing, 40)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear {
            Task {
                await vm.calculateLegInfo()
            }
        }
    }

    private func createLocationView(locationName: String, time: Double?, isLast: Bool) -> some View {
        HStack(alignment: .center, spacing: 5) {
            if let time = time {
                Text("\(time, specifier: "%.0f") MIN")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 50, alignment: .trailing)
                    .padding(.top, isLast ? -40 : -75)
            } else {
                Spacer().frame(width: 50)
            }

            VStack(spacing: 0) {
                RouteCircle()
                if !isLast {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1, height: 60)
                        .padding(.leading, 5)
                }
            }
            .padding(.leading, 5)

            Text(locationName)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading, 5)
                .padding(.top, isLast ? -6 : -40)
        }
        .padding(.vertical, 0)
    }
}

#Preview {
    let trip = Trip(
        start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech"),
        end_location: Hotel(address: "387 West Peachtree", name: "Hilton"),
        stops: [Restaurant(address: "85 5th St. NW Atlanta, GA 30308", name: "Moes"), GeneralLocation(address: "630 10th St NW, Atlanta, GA 30318", name: "QuikTrip")]
    )

    let user = User(id: "89379", name: "Austin", trips: [trip])
    var vm = UserViewModel(user: user)
    vm.current_trip = trip

    return RoutePlanListView(vm: vm)
}

struct RouteCircle: View {
    var body: some View {
        Circle()
            .fill(Color.white)
            .shadow(radius: 2)
            .frame(width: 12, height: 12)
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
