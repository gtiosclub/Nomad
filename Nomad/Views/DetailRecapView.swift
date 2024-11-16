//
//  DetailRecapView.swift
//  Nomad
//
//  Created by Shaunak Karnik on 10/3/24.
//

import SwiftUI
import PhotosUI

struct DetailRecapView: View {
    @State var selectedItems: [PhotosPickerItem] = []
    @State var recapImages: [Image] = []
    @ObservedObject var vm: UserViewModel
    @State var trip: Trip
    @State var images: [UIImage] = []
    @State var routePlanned: Bool = false
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    VStack (alignment: .leading){
                        Text(vm.current_trip?.getName() ?? "Trip Name")
                            .font(.system(size: 22, weight: .bold))
                            .padding(.vertical, 15)
                        ScrollView(.horizontal, showsIndicators: true) {
                            HStack {
                                ForEach(images, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame(width: 200.0, height: 150.0)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }.padding(.bottom, 30)
                                PhotosPicker(selection: $selectedItems,
                                             matching: .any(of: [.images, .not(.screenshots)])) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 10)
                                            .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [2]))
                                            .frame(width: 200, height: 150)
                                        Image(systemName: "plus.circle")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30)
                                    }.padding(.bottom, 30)
                                }
                            }
                        }   .scrollIndicators(.visible)
                            .onChange(of: selectedItems) { _, _ in
                                if !selectedItems.isEmpty {
                                    for eachItem in selectedItems {
                                        Task {
                                            if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                                                if let image = UIImage(data: imageData) {
                                                    images.append(image)
                                                    print("image appended")
                                                    FirebaseViewModel.vm.storeImageAndReturnURL(image: image, tripID: trip.id, completion: { url in })
                                                }
                                            }
                                        }
                                    }
                                    selectedItems.removeAll()
                                }
                            }
                        Text("Trip Details")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.bottom, 10)
                        HStack {
                            Image(systemName: "mappin")
                            Text((vm.current_trip?.getEndLocation().getName() ?? "Destination"))
                        }.padding(.bottom, 10)
                    }
                    Spacer()
                }
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 147/255, green: 201/255, blue: 201/255),Color.nomadLightBlue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 155, height: 87)
                        VStack {
                            Text(String(format: "%.1f", round((trip.route?.totalDistance() ?? 0.0) * 10) / 10))
                                .font(.system(size: 30))
                            Text("miles traveled")
                        }
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(LinearGradient(gradient: Gradient(colors: [Color(red: 147/255, green: 201/255, blue: 201/255),Color.nomadLightBlue]), startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 155, height: 87)
                        VStack {
                            Text(String(format: "%.1f", round((trip.route?.totalTime() ?? 0.0) / 3600 * 10) / 10))
                                .font(.system(size: 30))
                            Text("hours spent")
                        }
                    }
                }.padding(.bottom, 40)
                HStack {
                    Text("Here are the places you stopped!")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.bottom, 10)
                    Spacer()
                }
                RoutePlanListView(vm: vm, reload: $routePlanned)
                    .padding(.bottom, 30)
                HStack {
                    Text("Here's how you moved around")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                }.padding(.bottom, 10)
                RoutePreviewView(vm: vm, trip: Binding.constant(trip), currentStopLocation: Binding.constant(nil))
                    .frame(height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 5.0)
                
            }.padding(.horizontal, 30)
                .padding(.bottom, 30)
        }.onAppear{
            vm.setCurrentTrip(trip: trip)
            Task {
                await vm.updateRoute()
                routePlanned = true
                var imageURLs: [String] = await FirebaseViewModel.vm.getAllImages(tripID: trip.id)
                for image in imageURLs {
                    FirebaseViewModel.vm.getImageFromURL(urlString: image, completion: { uiImage in
                        images.append(uiImage!)
                    })
                }
            }
        }
        .onChange(of: routePlanned) {}
    }
}



//#Preview {
//    DetailRecapView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville", coverImageURL: "https://pixabay.com/get/g396fa4b9bb9c1731092f12dcf2bb686fc52caaa5dc7a6f7a9edafe2c402bfe67b1a3affcdae0731b43338a151f0d3b21_640.jpg"), Trip(start_location: Activity(address: "123 Start St", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Boston"), end_location: Hotel(address: "456 End Ave", name: "End Hotel", latitude: 34.0522, longitude: -118.2437, city: "Seattle"), name: "Cross Country", coverImageURL: "https://pixabay.com/get/g1a5413e9933d659796d14abf3640f03304a18c6867d6a64987aa896e3b6ac83ccc2ac1e5a4a2a7697a92161d1487186b7e2b6d4c17e0f11906a0098eef1da812_640.jpg"), Trip(start_location: Activity(address: "789 Another St", name: "Johnson Family Spring Retreat", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "123 Another Ave", name: "Another Hotel", latitude: 34.0522, longitude: -118.2437, city: "Blue Ridge"), name: "GA Mountains", coverImageURL: "https://pixabay.com/get/gceb5f3134c78efcc8fbd206f7fb8520990df3bb7096474f685f8c3cb95749647d5f4752db8cf1521e69fa27b940044b7f477dd18e51de093dd7f79b833ceca1b_640.jpg")])), trip: Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville", coverImageURL: "https://pixabay.com/get/g396fa4b9bb9c1731092f12dcf2bb686fc52caaa5dc7a6f7a9edafe2c402bfe67b1a3affcdae0731b43338a151f0d3b21_640.jpg"))
//}
