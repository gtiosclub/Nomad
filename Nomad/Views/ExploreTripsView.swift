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
    @State var previous_trips: [Trip] = []
    @State var community_trips: [Trip] = []
    @State var pulled_trips: Bool = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        VStack(spacing: 0) {
                            HStack {
                                Text("Let's Explore, \(vm.user.getName().split(separator: " ").first!.replacingOccurrences(of: "austinhuguenard", with: "Austin"))!")
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
                                .offset(y: 20)
                            }
                            
                            HStack {
                                HStack {
                                    ZStack {
                                        MapPinShape()
                                            .fill(Color.white)
                                            .frame(width: 10, height: 16) // Adjust as needed
                                        
                                        Circle()
                                            .frame(width: 4, height: 4)
                                            .foregroundColor(.nomadDarkBlue)
                                            .offset(y: -3)
                                            .zIndex(3)
                                    }
                                    .padding(.leading, 10)
                                    .padding(.vertical, 5)
                                    
                                    Text("\(vm.currentCity ?? "Retrieving Location")")
                                        .foregroundStyle(Color.white)
                                        .padding(.leading, 5)
                                        .padding(.trailing, 10)
                                        .font(.system(size: 14))
                                }
                                .padding(1)
                                .background(Color.nomadDarkBlue)
                                .cornerRadius(14)
                                .foregroundColor(.black.opacity(0.7))
                                .padding(.leading, 5)
                                .padding(.horizontal, 10)
                                
                                Spacer()
                            }
                        }
                        .padding(.bottom, 15)
                        
                        // Itineraries
                        VStack(alignment: .leading) {
                            SectionHeaderView(vm: vm, title: "Upcoming Trips", trips: vm.user.trips)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: 15) {
                                    ForEach($current_trips.wrappedValue) { trip in
                                        NavigationLink(destination: {
                                            PreviewRouteView(vm: vm, trip: trip)
                                        }, label: {
                                            TripGridView(trip: trip)
                                                .frame(alignment: .top)
                                                .frame(minWidth: 140)
                                        })
                                        .simultaneousGesture(
                                            LongPressGesture(minimumDuration: 0.5)
                                        )
                                        .contextMenu {
                                            Button(action: {
                                                //TODO: delete trip
                                            }) {
                                                Text("Delete")
                                                Image(systemName: "trash")
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                            
                            Divider()
                                .foregroundStyle(Color.nomadDarkBlue.opacity(0.3))
                            
                            SectionHeaderView(vm: vm, title: "Previous Trips", trips: vm.previous_trips)
                                .padding(.top, 5)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: 15) {
                                    ForEach($previous_trips.wrappedValue) { trip in
                                        NavigationLink(destination: {
                                            PreviewRouteView(vm: vm, trip: trip)
                                        }, label: {
                                            TripGridView(trip: trip)
                                                .frame(alignment: .top)
                                                .frame(minWidth: 140)
                                        })
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
                            
                            Divider()
                                .foregroundStyle(Color.nomadDarkBlue.opacity(0.3))
                            
                            SectionHeaderView(vm: vm, title: "Community Favorites", trips: vm.community_trips)
                                .padding(.top, 5)
                                .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                HStack(spacing: 15) {
                                    ForEach($community_trips.wrappedValue) { trip in
                                        NavigationLink(destination: {
                                            PreviewRouteView(vm: vm, trip: trip)
                                        }, label: {
                                            TripGridView(trip: trip)
                                                .frame(alignment: .top)
                                                .frame(minWidth: 140)
                                        })
                                    }
                                }
                            }
                            .padding(.horizontal, 15)
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
                                .background(Color.nomadDarkBlue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 2)
                        }
                        .padding(.bottom, 10)
                        .padding(.trailing, 15)
                    }
                }
            }
        }
        .task {
            if !pulled_trips {
                print("populating trips and current location")
                
                let populateTrips = Task { await vm.populateUserTrips() }
                let getCity = Task { await vm.getCurrentCity() }
                
                await populateTrips.value
                await getCity.value
                
                pulled_trips = true
                
                current_trips = vm.user.trips
                previous_trips = vm.user.pastTrips
                community_trips = vm.community_trips
            }
        }
        .onAppear() {
            if pulled_trips {
                print("repopulating trips")
                current_trips = vm.user.trips
                previous_trips = vm.user.pastTrips
                community_trips = vm.community_trips
            }
        }
        .onChange(of: current_trips, initial: true) {}
        .onChange(of: previous_trips, initial: true) {}
        .onChange(of: community_trips, initial: true) {}
        .onChange(of: vm.user.trips, initial: true) { old, new in
            current_trips = vm.user.trips
        }
        .onChange(of: vm.current_trip, initial: true) {}
        .onChange(of: vm.current_trip?.coverImageURL, initial: true) {}
    }
    
    struct SectionHeaderView: View {
        var vm: UserViewModel
        var title: String
        var trips: [Trip]
        @State var navigateToAll: Bool = false
        
        var body: some View {
            HStack {
                Text(title)
                    .font(.system(size: 18))
                Spacer()
                Button(action: {
                    navigateToAll = true
                }) {
                    Text("View all")
                        .foregroundColor(.gray)
                }
                .navigationDestination(isPresented: $navigateToAll, destination: {
                    ViewAllTripsView(vm: vm, header: title, trips: trips)
                })
            }
            .padding(.top, 5)
            .padding(.bottom, 3)
        }
    }
    
    struct TripGridView: View {
        @ObservedObject var trip: Trip
        @State private var textWidth: CGFloat = 140
        @State var imageUrl: String = ""
        
        var body: some View {
            VStack(alignment: .leading) {
                if trip.coverImageURL.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: max(textWidth, 140)) // Use the measured width
                        .frame(height: 120)
                        .cornerRadius(10)
                } else {
                    AsyncImage(url: URL(string: trip.coverImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: max(textWidth, 140)) // Use the measured width
                            .frame(height: 120)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.5), radius: 5, y: 3)
                    } placeholder: {
                        ProgressView()
                            .frame(width: max(textWidth, 140)) // Use the measured width
                            .frame(height: 120)
                            .cornerRadius(10)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(trip.name.isEmpty ? "New Trip" : trip.name)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                        .padding(.leading, 5)
                    
                    HStack(spacing: 1) {
                        Text(trip.getStartCity())
                            .foregroundStyle(.gray)
                            .font(.system(size: 12))
                        
                        HStack(spacing: 1) {
                            Circle()
                                .frame(width: 1, height: 1)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Rectangle()
                                .frame(width: 3, height: 1)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Rectangle()
                                .frame(width: 3, height: 1)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Circle()
                                .frame(width: 1, height: 1)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        
                        Text(trip.getEndCity())
                            .foregroundStyle(.gray)
                            .font(.system(size: 12))
                    }
                    .padding(.leading, 5)
                    .padding(.bottom, 5)
                    .padding(.trailing, 5)
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .onAppear {
                                    textWidth = geometry.size.width // Capture the width of the HStack
                                }
                        }
                    )
                    
                    Text("\(intToWords(trip.getStops().count)) \(trip.getStops().count == 1 ? "stop" : "stops")")
                        .font(.system(size: 12))
                        .padding(3)
                        .padding(.horizontal, 5)
                        .background(Color.nomadDarkBlue.opacity(0.5))
                        .cornerRadius(10)
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.leading, 5)
                }
                .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 5)
            .padding(.horizontal, 2)
            .onAppear {
                imageUrl = trip.coverImageURL
            }
            .onChange(of: $trip.coverImageURL.wrappedValue, initial: true) { old, new in
                imageUrl = trip.coverImageURL
            }
            .onChange(of: imageUrl, initial: true) { old, new in
                print("got new image url \(new)")
            }
        }
        
        func intToWords(_ number: Int) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            return formatter.string(from: NSNumber(value: number)) ?? ""
        }
    }
    
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY)) // Bottom center
            path.addLine(to: CGPoint(x: rect.minX, y: rect.minY)) // Top left
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY)) // Top right
            path.closeSubpath()
            return path
        }
    }
    
    struct MapPinShape: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()
            
            // Circle at the top
            let circleRadius = rect.width * 0.5
            let circleCenter = CGPoint(x: rect.midX, y: circleRadius)
            path.addArc(center: circleCenter, radius: circleRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: false)
            
            // Triangle at the bottom
            path.move(to: CGPoint(x: rect.midX - circleRadius, y: circleRadius + 1.5))
            path.addLine(to: CGPoint(x: rect.midX + circleRadius, y: circleRadius + 1.5))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY - 1))
            path.closeSubpath()
            
            return path
        }
    }
}
    
    #Preview {
        ExploreTripsView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")))
    }
