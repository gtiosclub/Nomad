////
////  POIDetailView.swift
////  Nomad
////
////  Created by Connor on 10/17/24.
////
import SwiftUI

struct POIDetailView: View {
    @State private var isExpanded = false
    var name: String
    var address: String
    var distance: Double
    var phoneNumber: String
    var image: String
    var rating: Double
    var price: String
    var time: Double
    var latitude: Double
    var longitude: Double
    var city: String
    @ObservedObject var vm: UserViewModel
    @ObservedObject var aiVM: AIAssistantViewModel
    
    @State private var isAdded: Bool = false
    
    
    
    var body: some View {
        VStack(spacing: 10) {
            // Top part: Image and POI Information
            HStack(alignment: .center, spacing: 1) {
                
                VStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            if(!isAdded) {
                                isAdded = true // Set state to true after button click
            
                                var poi = GeneralLocation(address: address, name: name, latitude: latitude, longitude: longitude)
                                
                                addStop(poi)
                                
                            }
                        }
                       
                    }) {
                        ZStack {
                            Circle()
                                .fill(isAdded ? Color.green : Color.white)
                                .frame(width: 30, height: 30)
                                .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            
                            Image(systemName: isAdded ? "checkmark" : "plus")
                                .foregroundColor(isAdded ? .white : .gray)
                                .font(.system(size: 24))
                                .bold()
                        }
                    }
                        
                    Spacer()
                    
                }
                
                VStack {
                    AsyncImage(url: URL(string: image)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 60)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                    } placeholder: {
                        ProgressView()
                            .frame(width: 80, height: 60)
                            .cornerRadius(10)
                            .padding(.horizontal, 10)
                    }
                    
                    Text("\(time == floor(time) ? "\(Int(time))" : String(format: "%.1f", time)) min")
                        .font(.headline)
                    
                    Text("+\(distance == floor(distance) ? "\(Int(distance))" : String(format: "%.1f", distance)) mi")
                        .font(.subheadline)
                }
                
                
                
                // POI Information
                VStack(alignment: .leading, spacing: 5) {
                    Text(name)
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .lineLimit(nil) // Allow unlimited lines
                        .multilineTextAlignment(.leading)
                    
                    HStack(spacing: 4) {
                        ForEach(0...4, id: \.self) { index in
                            if Double(index) >= rating {
                                Image(systemName: "star")
                            } else {
                                if Double(index) + 1 > rating {
                                    Image(systemName: "star.leadinghalf.filled") // Full star
                                } else {
                                    Image(systemName: "star.fill")
                                }
                            }

                        }
                        
                        Text("• \(price)")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                    } .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Phone Button
                    Button(action: {
                        if let phoneURL = URL(string: "tel://\(phoneNumber)") {
                            UIApplication.shared.open(phoneURL)
                        }
                    }) {
                        Label(phoneNumber, systemImage: "phone")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                            .underline()
                    }
                }

            }
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(radius: 5)
            )
            .padding()
            
            // Overlay the expanded image when `isExpanded` is true
            if isExpanded {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        withAnimation {
                            isExpanded.toggle()
                        }
                    }

                AsyncImage(url: URL(string: image)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 225)
                        .cornerRadius(42)
                        .shadow(radius: 10)
                } placeholder: {
                    ProgressView()
                        .frame(width: 300, height: 225)
                        .cornerRadius(42)
                        .shadow(radius: 10)
                }
                .onTapGesture {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.nomadLightBlue)
                .shadow(radius: 5)
        )
        .padding()
    }
    
    func addStop(_ stop: any POI) {
        Task {
            await vm.addStop(stop: stop)
            
            guard let start_loc = vm.current_trip?.getStartLocation() else { return }
            guard let end_loc = vm.current_trip?.getEndLocation() else { return }
            guard let all_stops = vm.current_trip?.getStops() else { return }
            
            var all_pois: [any POI] = []
            all_pois.append(start_loc)
            all_pois.append(contentsOf: all_stops)
            all_pois.append(end_loc)
            
            if let newRoutes = await MapManager.manager.generateRoute(pois: all_pois) {
                vm.setTripRoute(route: newRoutes[0])
            }
        }
    }
}
#Preview {
    POIDetailView(name: "Speedway", address: "5 XYZ St, Atlanta, GA 06843", distance: 4.5, phoneNumber: "+19055759875", image: "", rating: 4.5, price: "$$", time: 4.2, latitude: 35.0, longitude: 34.0, city: "adsfsad", vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")), aiVM: AIAssistantViewModel())
}
