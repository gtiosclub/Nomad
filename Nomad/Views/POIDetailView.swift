//
//  POIDetailView.swift
//  Nomad
//
//  Created by Connor on 10/17/24.
//

import SwiftUI

struct POIDetailView: View {
    
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
            HStack(alignment: .top, spacing: 10) {
                Button(action: {
                    if(!isAdded) {
                        isAdded = true // Set state to true after button click
                        
                        let locationType = aiVM.currentLocationType
    
                        var poi = GeneralLocation(address: address, name: name, latitude: latitude, longitude: longitude)
                        
                        Task {
                            await vm.addStop(stop: poi)
                            
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
                }) {
                    Image(systemName: "plus.circle")
                        .resizable()
                        .frame(width: 50)
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
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white)
                .shadow(radius: 5)
        )
        .padding()
    }
}


//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

#Preview {
    POIDetailView(name: "Speedway", address: "5 XYZ St, Atlanta, GA 06843", distance: 4.5, phoneNumber: "+19055759875", image: "", rating: 4.5, price: "$$", time: 4.2, latitude: 35.0, longitude: 34.0, city: "adsfsad", vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")), aiVM: AIAssistantViewModel())
}
