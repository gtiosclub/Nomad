//
//  ExploreTripsView.swift
//  Nomad
//
//  Created by Lingchen Xiao on 10/3/24.
//

import SwiftUI

struct ExploreTripsView: View {
    @ObservedObject var vm: UserViewModel
    @State private var currentCity: String? = nil
    @State var current_trips: [Trip] = []
    @State var pulled_trips: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .padding(.trailing, 0)
                                .padding(.leading)
                            if let city = vm.currentCity {
                                Text("\(city)")
                                    .font(.headline)
                            } else {
                                Text("Retrieving Location")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                                                
                        HStack {
                            Text("Plan your next trip, \(vm.user.getName().split(separator: " ").first!)!")
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
                        
                        // Itineraries
                        VStack(alignment: .leading) {
                            SectionHeaderView(title: "Upcoming Itineraries")
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach($current_trips.wrappedValue) { trip in
                                        NavigationLink(destination: {
                                            PreviewRouteView(vm: vm, trip: trip)
                                        }, label: {
                                            TripGridView(trip: trip)
                                                .frame(alignment: .top)
                                        })
                                    }
                                }
                                .onChange(of: vm.user.trips, initial: true) { oldTrips, newTrips in
                                    current_trips = newTrips
                                }
                            }
                            .padding(.horizontal)
                            
                            SectionHeaderView(title: "Previous Itineraries")
                                .padding(.top, 5)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(vm.previous_trips) { trip in
                                        NavigationLink(destination: {
                                            PreviewRouteView(vm: vm, trip: trip)
                                        }, label: {
                                            TripGridView(trip: trip)
                                                .frame(alignment: .top)
                                        })
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            SectionHeaderView(title: "Community Favorites")
                                .padding(.top, 5)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(vm.community_trips) { trip in
                                        NavigationLink(destination: {
                                            PreviewRouteView(vm: vm, trip: trip)
                                        }, label: {
                                            TripGridView(trip: trip)
                                                .frame(alignment: .top)
                                        })
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        NavigationLink(destination: ItineraryPlanningView(vm: vm)) {
                            Image(systemName: "plus")
                                .font(.system(size: 24))
                                .padding()
                                .background(Color(.systemGray4))
                                .foregroundColor(.black)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        .padding(.bottom, 10)
                        .padding(.trailing, 15)
                    }
                }
            }
        }.task {
            print("populating trips and current location")
//            vm.populate_my_trips()
//            vm.populate_previous_trips()
//            vm.populate_community_trips()
            if !pulled_trips {
                await vm.populateUserTrips()
                await vm.getCurrentCity()
                pulled_trips = true
            }
            current_trips = vm.user.trips
        }
    }
    
    struct SectionHeaderView: View {
        var title: String
        var body: some View {
            HStack {
                Text(title)
                    .font(.headline)
                    .bold()
                Spacer()
                Button(action: {}) {
                    Text("View all")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 5)
        }
    }
    
    struct TripGridView: View {
        @StateObject var trip: Trip
        
        var body: some View {
            VStack {
                if trip.coverImageURL.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                } else {
                    AsyncImage(url: URL(string: trip.coverImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
//                            .id($trip.coverImageURL.wrappedValue)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 120, height: 120)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                    }
                    .onChange(of: trip.coverImageURL, initial: true) { old, new in
                        // print("changing image url \(old) \(new)")
                    }
                }
                
                Text(trip.name.isEmpty ? "New Trip" : trip.name)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .frame(width: 120)
                    .font(.system(size: 14))
                    .foregroundStyle(.black)
            }
            .padding(.vertical, 5)
//            .onChange(of: trip, initial: true) { old, new in
//                print("changing trip info \(old.coverImageURL) \(new.coverImageURL)")
//            }
        }
    }
}
    
    #Preview {
        ExploreTripsView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")))
    }
