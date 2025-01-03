//
//  RoutePlanListView.swift
//  Nomad
//
//  Created by Brayden Huguenard on 10/2/24.
//

import SwiftUI

struct RoutePlanListView: View {
    @ObservedObject var vm: UserViewModel
    @Binding var reload: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            if let startLocation = vm.current_trip?.getStartLocation() {
                createLocationView(locationName: "Start \(("at " + startLocation.name).replacingOccurrences(of: "at Start Location", with: "in \(vm.current_trip!.getStartCity())"))", time: nil, isLast: false)
            }

            if let stops = vm.current_trip?.getStops() {
                if $reload.wrappedValue {
                    ForEach(stops.indices, id: \.self) { index in
                        let stopName = stops[index].name
                        let time = vm.times[safe: index]
                        createLocationView(locationName: "Stop at \(stopName)", time: time, isLast: false)
                    }
                }
            }

            if let endLocation = vm.current_trip?.getEndLocation() {
                createLocationView(locationName: "End \(("at " + endLocation.name).replacingOccurrences(of: "at End Location", with: "in \(vm.current_trip!.getEndCity())"))", time: vm.times.last, isLast: true)
            }
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 15)
        .padding(.leading, 0)
        .frame(maxWidth: UIScreen.main.bounds.width)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }

    private func createLocationView(locationName: String, time: Double?, isLast: Bool) -> some View {
        HStack(alignment: .center, spacing: 5) {
            if let time = time {
                let hours = time / 60
                Text(time > 60 ? "\(hours, specifier: "%.1f") HR" : "\(time, specifier: "%.0f") MIN")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(width: 50, alignment: .trailing)
                    .padding(.bottom, 15)
                    .padding(.top, isLast ? -15 : -30)
//                    .padding(.leading, -5)
//                    .padding(.trailing, 5)
            } else {
                Spacer().frame(width: 50)
            }

            VStack(spacing: 0) {
                RouteCircle()
                if !isLast {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 1, height: 20)
                        .padding(.leading, 0)
                }
            }
            .padding(.leading, 10)

            Text(locationName)
                .lineLimit(1)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.leading, 5)
                .padding(.top, isLast ? -5 : -20)
                .lineLimit(1)
        }
        .padding(.vertical, 0)
    }
}

#Preview {
    let trip = Trip(
        start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech", latitude: 0.0, longitude: 0.0),
        end_location: Hotel(address: "387 West Peachtree, Atlanta", name: "Hilton", latitude: 0.0, longitude: 0.0),
        stops: [Restaurant(address: "85 5th St. NW, Atlanta, GA 30308", name: "Moes", latitude: 0.0, longitude: 0.0), GeneralLocation(address: "630 10th St NW, Atlanta, GA 30318", name: "QuikTrip", latitude: 0.0, longitude: 0.0)]
    )

    let user = User(id: "89379", name: "Austin", trips: [trip])
    var vm = UserViewModel(user: user)
    vm.current_trip = trip
    @State var reload = true
    return RoutePlanListView(vm: vm, reload: $reload)
}

struct RouteCircle: View {
    var body: some View {
        Circle()
            .stroke(Color(red: 0.18, green: 0.55, blue: 0.54), lineWidth: 1.5)
            .background(Circle().fill(Color.white))
            .frame(width: 12, height: 12)
            .shadow(radius: 0.2)
    }
}

extension Array {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
