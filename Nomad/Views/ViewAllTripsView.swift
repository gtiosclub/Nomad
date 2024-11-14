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
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        
                        HStack {
                            Text("Upcoming Itineraries")
                                .bold()
                                .font(.system(size: 20))
                                .padding(.horizontal)
                            
                            Spacer()
                            
                            // Profile picture
                            ZStack {
                                Ellipse()
                                    .fill(Color.gray)
                                    .frame(width: 40, height: 40)
                                Text((vm.user.getName() ?? "User").prefix(1))
                                    .foregroundColor(.white)
                                    .font(.system(size: 25))
                            }
                            .padding(.trailing)
                        }
                        
                        NavigationLink(destination: ExploreTripsView()) {
                            HStack {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                    .padding(.trailing, -50)

                                Text("Back")
                                    .font(.system(size: 17))
                                    .padding()
                                    .foregroundColor(.blue)
                                    .cornerRadius(8)
                                }
                                .padding(.leading, 18)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            ScrollView(.horizontal) {
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                                    ForEach(UserViewModel.my_trips) { trip in
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
        }.task() {
            print("populating trips")
            await vm.populateUserTrips()
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
    
    struct ExploreTripsView: View {
        var body: some View {
            Text("Explore Trips View")
                .navigationTitle("Explore Trips")
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
                    
                }
                
                Text(trip.name)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .frame(width: 120)
                    .font(.system(size: 14))
                    .foregroundStyle(.black)
                
                HStack {
                  //  Text(trip.getStartLocation().name)
                    //    .font(.caption)
                    //    .padding(4)
                    //    .background(Color.gray.opacity(0.7))
                   //     .cornerRadius(5)
                   //     .foregroundColor(.black)
                                
               //     Text(trip.getEndLocation().name)
                //        .font(.caption)
                //        .padding(4)
                //        .background(Color.gray.opacity(0.5))
                //        .cornerRadius(5)
                 //       .foregroundColor(.black)

                    Text("\(trip.getStops().count) \(trip.getStops().count == 1 ? "stop" : "stops")")
                        .font(.caption)
                        .padding(4)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(5)
                        .foregroundColor(.black)
                }
                .padding(.top, 2)
            }
            .padding(.leading, 5)
            .padding(.vertical, 5)
            .frame(width: 180)
            .onChange(of: trip, initial: true) { old, new in
                print("changing trip info \(old.coverImageURL) \(new.coverImageURL)")
            }
        }
    }
}
    
    #Preview {
        ViewAllTripsView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")))
    }

