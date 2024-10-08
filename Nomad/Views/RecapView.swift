//
//  RecapView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct RecapView: View {
    @ObservedObject var vm: UserViewModel
        
    var body: some View {
        NavigationStack {
            VStack {
                Text("Let's see where you've been!")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 10)]
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(vm.getTrips()) { trip in
                        NavigationLink {
                            DetailRecapView(vm: vm, trip: trip)
                        } label: {
                            CardView(title: trip.getStartLocation().getName() + " to " + trip.getEndLocation().getName(), attributes: ["4-6 Hours", "Pet-friendly"])
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                Spacer()
            }.padding(20)
        }
    }
}

struct CardView: View, Identifiable {
    let id = UUID()
    let title: String
    let attributes: [String]

    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 165, height: 135)
                .cornerRadius(10)

            Text(title)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 5)

            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(attributes, id: \.self) { attribute in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 20)
                        .overlay(Text(attribute)
                                    .font(.caption2))
                }
            }
        }
    }
}

#Preview {
    RecapView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"), stops: [Restaurant(address: "85 5th St. NW Atlanta, GA 30308", name: "Moes"), GeneralLocation(address: "630 10th St NW, Atlanta, GA 30318", name: "QuikTrip")]), Trip(start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Marietta"), end_location: Hotel(address: "387 West Peachtree", name: "Mariott"), stops: [Restaurant(address: "85 5th St. NW Atlanta, GA 30308", name: "Moes"), GeneralLocation(address: "630 10th St NW, Atlanta, GA 30318", name: "QuikTrip")])])))
}

