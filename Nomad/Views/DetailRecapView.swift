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
                            .font(.system(size: 20, weight: .bold))
                            .padding(.vertical, 10)
                        
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
                                    }.padding(.bottom, 20)
                                }
                            }
                        }
                        .scrollIndicators(.visible)
                        .onChange(of: selectedItems) { _, _ in
                            if !selectedItems.isEmpty {
                                for eachItem in selectedItems {
                                    Task {
                                        if let imageData = try? await eachItem.loadTransferable(type: Data.self) {
                                            if let image = UIImage(data: imageData) {
                                                images.append(image)
                                                print("image appended")
                                                FirebaseViewModel.vm.storeImageAndReturnURL(image: image, tripID: trip.id, completion: {
                                                    url in
                                                })
                                            }
                                        }
                                    }
                                }
                            }
                            selectedItems.removeAll()
                        }
                        
                        Text("Trip Details")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.bottom, 0)
                        
                        HStack {
                            HStack {
                                ZStack {
                                    MapPinShape()
                                        .fill(Color.gray)
                                        .frame(width: 10, height: 16) // Adjust as needed
                                    
                                    Circle()
                                        .frame(width: 4, height: 4)
                                        .foregroundColor(.white)
                                        .offset(y: -3)
                                        .zIndex(3)
                                }
//                                    .padding(.leading, 10)
                                .padding(.vertical, 0)
                                
                                HStack(spacing: 4) {
                                    Text(trip.getStartCity())
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 16))
                                    
                                    HStack(spacing: 1) {
                                        Circle()
                                            .frame(width: 1, height: 1)
                                            .foregroundColor(.gray)
                                        
                                        Rectangle()
                                            .frame(width: 3, height: 1)
                                            .foregroundColor(.gray)
                                        
                                        Rectangle()
                                            .frame(width: 3, height: 1)
                                            .foregroundColor(.gray)
                                        
                                        Circle()
                                            .frame(width: 1, height: 1)
                                            .foregroundColor(.gray)
                                        
                                        Image(systemName: "car.side")
                                            .font(.system(size: 16))
                                            .scaleEffect(x: -1, y: 1)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Text(trip.getEndCity())
                                        .foregroundStyle(.gray)
                                        .font(.system(size: 16))
                                }
                                .padding(.leading, 5)
                                .padding(.bottom, 1)
                                .padding(.trailing, 5)
                            }
                            .padding(1)
                            .cornerRadius(14)
                            .foregroundColor(.black.opacity(0.7))
                            .padding(.trailing, 10)
                            .padding(.leading, 0)
                            
                            Spacer()
                        }
                    }
                    Spacer()
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        Text("Time")
                            .padding(.top, 0)
                            .font(.system(size: 14))
                            .foregroundStyle(.black)
                        
                        Text(formatTimeDuration(duration: trip.route?.route?.expectedTravelTime ?? TimeInterval(0)))
                            .padding(.bottom, 0)
                            .font(.system(size: 22))
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                        Text("Started")
                            .padding(.top, 0)
                            .font(.system(size: 14))
                            .foregroundStyle(.black)
                        
                        HStack {
                            Text("\(convertDateToShortFormat(trip.getStartDate())),")
                                .padding(.bottom, 0)
                                .font(.system(size: 22))
                                .foregroundStyle(.black)
                            
                            Text(trip.getStartTime())
                                .padding(.bottom, 0)
                                .font(.system(size: 22))
                                .foregroundStyle(.black)
                        }
                    }
                    .padding(.trailing, 10)
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("Distance")
                            .padding(.top, 0)
                            .font(.system(size: 14))
                            .foregroundStyle(.black)
                        
                        Text(formatDistance(distance: trip.route?.totalDistance() ?? 0))
                            .padding(.bottom, 0)
                            .font(.system(size: 22))
                            .foregroundStyle(.black)
                        
                        Spacer()
                        
                        Text("Ended")
                            .padding(.top, 0)
                            .font(.system(size: 14))
                            .foregroundStyle(.black)
                        
                        Text(convertDateToShortFormat(trip.getEndDate()))
                            .padding(.bottom, 0)
                            .font(.system(size: 22))
                            .foregroundStyle(.black)
                    }
                    .padding(.trailing, 0)
                    
                    Spacer()
                }
                .padding(.vertical)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.leading, 15)
                .onChange(of: vm.times) {}
                .frame(alignment: .leading)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.black, lineWidth: 0.5)
                )
                .padding(.horizontal, 0)
                .padding(.bottom, 20)
                .padding(.top, 0)
                
                HStack {
                    Text("The places you stopped")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.bottom, 10)
                    Spacer()
                }
                
                EnhancedRoutePlanListView(vm: vm, isEditable: false)
                    .padding(.bottom, 20)
                
                HStack {
                    Text("How you moved around")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                }
                .padding(.bottom, 10)
                
                RouteMapView(vm: vm, trip: Binding.constant(trip), currentStopLocation: Binding.constant(nil))
                    .frame(height: 400)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(radius: 5.0)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 30)
        }
        .onAppear{
            vm.setCurrentTrip(trip: trip)
            Task {
                await vm.updateRoute()
                vm.populateLegInfo()
                routePlanned = true
                let imageURLs: [String] = await FirebaseViewModel.vm.getAllImages(tripID: trip.id)
                for image in imageURLs {
                    FirebaseViewModel.vm.getImageFromURL(urlString: image, completion: { uiImage in
                        images.append(uiImage!)
                    })
                }
            }
        }
        .onChange(of: routePlanned) {
            vm.setCurrentTrip(trip: trip)
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
    
    func convertDateToShortFormat(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM-dd-yyyy"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "MMM. d"
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return "" // Return nil if the date string is invalid
        }
    }
    
    func formatTimeDuration(duration: TimeInterval) -> String {
        let minsLeft = Int(duration.truncatingRemainder(dividingBy: 3600))
        return "\(Int(duration / 3600)) hr \(Int(minsLeft / 60)) min"
    }
    
    func formatDistance(distance: Double) -> String {
        return String(format: "%.0f miles", distance)
    }
}



//#Preview {
//    DetailRecapView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville", coverImageURL: "https://pixabay.com/get/g396fa4b9bb9c1731092f12dcf2bb686fc52caaa5dc7a6f7a9edafe2c402bfe67b1a3affcdae0731b43338a151f0d3b21_640.jpg"), Trip(start_location: Activity(address: "123 Start St", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Boston"), end_location: Hotel(address: "456 End Ave", name: "End Hotel", latitude: 34.0522, longitude: -118.2437, city: "Seattle"), name: "Cross Country", coverImageURL: "https://pixabay.com/get/g1a5413e9933d659796d14abf3640f03304a18c6867d6a64987aa896e3b6ac83ccc2ac1e5a4a2a7697a92161d1487186b7e2b6d4c17e0f11906a0098eef1da812_640.jpg"), Trip(start_location: Activity(address: "789 Another St", name: "Johnson Family Spring Retreat", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "123 Another Ave", name: "Another Hotel", latitude: 34.0522, longitude: -118.2437, city: "Blue Ridge"), name: "GA Mountains", coverImageURL: "https://pixabay.com/get/gceb5f3134c78efcc8fbd206f7fb8520990df3bb7096474f685f8c3cb95749647d5f4752db8cf1521e69fa27b940044b7f477dd18e51de093dd7f79b833ceca1b_640.jpg")])), trip: Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville", coverImageURL: "https://pixabay.com/get/g396fa4b9bb9c1731092f12dcf2bb686fc52caaa5dc7a6f7a9edafe2c402bfe67b1a3affcdae0731b43338a151f0d3b21_640.jpg"))
//}
