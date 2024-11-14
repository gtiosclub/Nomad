//
//  ViewAllTripsView.swift
//  Nomad
//
//  Created by amber verma on 10/24/24.
//

import SwiftUI

struct ViewAllTripsView: View {
    @ObservedObject var vm: UserViewModel
    @State private var currentCity: String? = nil
    var header: String
    @State var trips: [Trip]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text(header)
                            .bold()
                            .font(.system(size: 20))
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        // Profile picture
                        ZStack {
                            Ellipse()
                                .fill(Color.gray)
                                .frame(width: 40, height: 40)
                            Text((vm.user.getName()).prefix(1).uppercased())
                                .foregroundColor(.white)
                                .font(.system(size: 25))
                        }
                        .padding(.trailing)
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(trips) { trip in
                            NavigationLink(destination: {
                                PreviewRouteView(vm: vm, trip: trip)
                            }, label: {
                                TripGridView(trip: trip)
                                    .frame(alignment: .top)
                            })
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    struct TripGridView: View {
        @StateObject var trip: Trip
        
        var body: some View {
            VStack {
                if trip.coverImageURL.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 150, height: 150)
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                } else {
                    AsyncImage(url: URL(string: trip.coverImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                        //                            .id($trip.coverImageURL.wrappedValue)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 150, height: 150)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                    }
                    
                }
                
                Text(trip.name.isEmpty ? "New Trip" : trip.name)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .frame(width: 120)
                    .font(.system(size: 14))
                    .foregroundStyle(.black)
                    .padding(.bottom, 0)
                
                HStack {
                    Text("\(getCityName(trip.getStartLocation().address))")
                    Image(systemName: "arrowshape.right.fill")
                    Text("\(getCityName(trip.getEndLocation().address))")
                }
                .padding(4)
                .font(.caption)
                .background(Color.gray.opacity(0.4))
                .cornerRadius(5)
                .foregroundColor(.black)
                
                Text("\(trip.getStops().count) \(trip.getStops().count == 1 ? "stop" : "stops")")
                    .font(.caption)
                    .padding(4)
                    .background(Color.nomadDarkBlue)
                    .cornerRadius(5)
                    .foregroundColor(.white)
            }
            .padding(.bottom, 15)
            .padding(.leading, 5)
            .padding(.vertical, 5)
            .frame(width: 180)
            .onChange(of: trip, initial: true) { old, new in
                print("changing trip info \(old.coverImageURL) \(new.coverImageURL)")
            }
        }
    }
}

func getCityName(_ address: String) -> String {
    let addressSplit = address.split(separator: ",")
    if addressSplit.count > 1 {
        return addressSplit[1].trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
        return "City"
    }
}
    
//#Preview {
//    ViewAllTripsView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")))
//}

