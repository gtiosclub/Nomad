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
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .padding()
                                .padding(.trailing, 0)
                            if let city = vm.currentCity {
                                Text("\(city)")
                                    .font(.headline)
                            } else {
                                Text("Retrieving Location")
                                    .font(.headline)
                            }
                            Spacer()
                        }
                        .task {
                            await vm.getCurrentCity()
                        }
                        
                        //TEMPORARY JUST FOR MID SEM DEMO
                        NavigationLink(destination: AIAssistantView()) {
                            Text("Consult Atlas")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }.padding(.leading)
                        
                        HStack {
                            Text("Plan your next trip, \(vm.user?.getName().split(separator: " ").first ?? "User")!")
                                .bold()
                                .font(.system(size: 20))
                                .padding(.horizontal)
                            
                            Spacer()
                            
                            // Profile picture
                            ZStack {
                                Ellipse()
                                    .fill(Color.gray)
                                    .frame(width: 40, height: 40)
                                Text((vm.user?.getName() ?? "User").prefix(1))
                                    .foregroundColor(.white)
                                    .font(.system(size: 25))
                            }
                            .padding(.trailing)
                        }
                        
                        // Itineraries
                        VStack(alignment: .leading) {
                            SectionHeaderView(title: "My Itineraries")
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                HStack {
                                    ForEach(vm.my_trips) { trip in
                                        NavigationLink(destination: {
                                            PreviewRouteView(vm: vm, trip: trip)
                                        }, label: {
                                            TripGridView(tripName: trip.getName(), imageURL: trip.getCoverImageURL())
                                                .frame(alignment: .top)
                                        })
                                    }
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
                                            TripGridView(tripName: trip.getName(), imageURL: trip.getCoverImageURL())
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
                                            TripGridView(tripName:trip.getName(), imageURL: trip.getCoverImageURL())
                                                .frame(alignment: .top)
                                        })
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }.onAppear() {
            print("populating trips")
            vm.populate_my_trips()
            vm.populate_previous_trips()
            vm.populate_community_trips()
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
        var tripName: String
        var imageURL: String
        
        var body: some View {
            VStack {
                if imageURL.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 120)
                        .cornerRadius(10)
                        .padding(.horizontal, 10)
                } else {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 120, height: 120)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                    }
                }
                
                Text(tripName)
                    .lineLimit(3)
                    .multilineTextAlignment(.center)
                    .frame(width: 120)
                    .font(.system(size: 14))
                    .foregroundStyle(.black)
            }
            .padding(.vertical, 5)
        }
    }
}
    
    #Preview {
        ExploreTripsView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")))
    }

