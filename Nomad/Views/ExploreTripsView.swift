//
//  ExploreTripsView.swift
//  Nomad
//
//  Created by Lingchen Xiao on 10/3/24.
//
import SwiftUI

struct ExploreTripsView: View {
    @ObservedObject var mapManager: MapManager
    @ObservedObject var vm: UserViewModel
    @State private var currentCity: String? = nil
    @State var addTrip: Bool = false
    var trips: [Trip]
    var previousTrips: [Trip]
    var communityTrips: [Trip]
    
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
                                    ForEach(vm.user?.trips ?? []) { trip in
                                        NavigationLink(destination: {
                                            PreviewRouteView(mapManager: mapManager, vm: vm, trip: trip)
                                        }, label: {
                                            TripGridView(trip: trip)
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
                                    ForEach(previousTrips) { trip in
                                        NavigationLink(destination: {
                                            PreviewRouteView(mapManager: mapManager, vm: vm, trip: trip)
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
                                    ForEach(communityTrips) { trip in
                                        NavigationLink(destination: {
                                            PreviewRouteView(mapManager: mapManager, vm: vm, trip: trip)
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
                        NavigationLink(destination: ItineraryPlanningView(mapManager: mapManager, vm: vm)) {
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
        @ObservedObject var trip: Trip
        
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
                    } placeholder: {
                        ProgressView()
                            .frame(width: 120, height: 120)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                    }
                    .onChange(of: trip.coverImageURL, initial: true) { old, new in
                        print("changing image url \(old) \(new)")
                    }
                }
                
                Text(trip.getName())
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
    
//#Preview {
//    let communityTrips = [
//        Trip(start_location: Activity(address: "555 Favorite Rd", name: "Home", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "666 Favorite Ave", name: "Favorite Hotel 1", latitude: 34.0522, longitude: -118.2437, city: "Redwood"), name: "Redwood National Park", coverImageURL: "https://pixabay.com/get/g673050a33bee3cf92bec894e53c695a132e2a970d4f7d222d78b159fd1104eee8366931c93df76e5a40a270d2511770b03c239fcb15c83fdef1f7fa3e9642b86_640.jpg"),
//        Trip(start_location: Restaurant(address: "777 Favorite Rd", name: "Lorum ipsum Pebble Beach", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "888 Favorite Ave", name: "Favorite Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "San Francisco"), name: "LA to SF", coverImageURL: "https://pixabay.com/get/gef59add7afafe4b8e63759d2d0c8508b1f363e38a98223e996dead3532bca58282ea52ed2f01b1279904658ad34fcf6200724f2d7b8d926c60032636ac0868fe_640.jpg"),
//        Trip(start_location: Restaurant(address: "333 Old Rd", name: "Lorum Ipsum Pebble Beach, CA", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "444 Old Ave", name: "Previous Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "Boulder"), name: "Colorado Mountains", coverImageURL: "https://pixabay.com/get/g7bac398012f95e6306a5385a0a3e2d7f369e6feee01204d10a6eda3ef233f0f164e517a1e237e85434c9cfb3bf646e4905ed30cc75a5a913e720ad3921599b00_640.jpg")
//    ]
//    
//    let previousTrips = [
//        Trip(start_location: Activity(address: "111 Old Rd", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "222 Old Ave", name: "Previous Hotel 1", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), name: "Cool Restaurants", coverImageURL: "https://pixabay.com/get/g4cbe6d67903fd42c30ee9ac0421be29dcc1f1ff92afca7669ef4d3fd2ff04c1e5aeb563579a1bfa2b531cb31dc3557f2_640.jpg"),
//        Trip(start_location: Restaurant(address: "333 Old Rd", name: "Lorum Ipsum Pebble Beach, CA", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "444 Old Ave", name: "Previous Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "Orlando"), name: "ATL to Orlando", coverImageURL: "https://pixabay.com/get/g0802111096a3f85616459fb3973c45a5ad82695ca0d654f73a5c4f1fbb0106fc482049a0bfef0f1fd177ce4dc47b4d9f_640.jpg"),
//        Trip(start_location: Restaurant(address: "333 Old Rd", name: "Lorum Ipsum Pebble Beach, CA", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "444 Old Ave", name: "Previous Hotel 2", latitude: 34.0522, longitude: -118.2437, city: "Boston"), name: "Northeast States", coverImageURL: "https://pixabay.com/get/g6c408c1e15343a676c97c97682d0a682a546e589903d30fb298156deaaf4c0a6e8f78818c9de44f1f7a50c36e0f7472bd53e719507d9b106f061e2ec484e28ba_640.jpg")
//    ]
//    
//    let trips = [
//        Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville", coverImageURL: "https://pixabay.com/get/g396fa4b9bb9c1731092f12dcf2bb686fc52caaa5dc7a6f7a9edafe2c402bfe67b1a3affcdae0731b43338a151f0d3b21_640.jpg"),
//        Trip(start_location: Activity(address: "123 Start St", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Boston"), end_location: Hotel(address: "456 End Ave", name: "End Hotel", latitude: 34.0522, longitude: -118.2437, city: "Seattle"), name: "Cross Country", coverImageURL: "https://pixabay.com/get/g1a5413e9933d659796d14abf3640f03304a18c6867d6a64987aa896e3b6ac83ccc2ac1e5a4a2a7697a92161d1487186b7e2b6d4c17e0f11906a0098eef1da812_640.jpg"),
//        Trip(start_location: Activity(address: "789 Another St", name: "Johnson Family Spring Retreat", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "123 Another Ave", name: "Another Hotel", latitude: 34.0522, longitude: -118.2437, city: "Blue Ridge"), name: "GA Mountains", coverImageURL: "https://pixabay.com/get/gceb5f3134c78efcc8fbd206f7fb8520990df3bb7096474f685f8c3cb95749647d5f4752db8cf1521e69fa27b940044b7f477dd18e51de093dd7f79b833ceca1b_640.jpg")
//    ]
//    
//    ExploreTripsView(mapManager: .init(), vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")), trips: trips, previousTrips: previousTrips, communityTrips: communityTrips)
//}

