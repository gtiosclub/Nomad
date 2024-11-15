////
////  POIDetailView.swift
////  Nomad
////
////  Created by Connor on 10/17/24.
////
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
    @State private var isExpanded = false
    @State private var isAdded: Bool = false
    
    var addStop: (any POI) -> Void
    
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
                    
                    Button(action: {
                        withAnimation {
//                            isExpanded.toggle()
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isExpanded.toggle()
                            }
                        }
                    }) {
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
                    }
                    .buttonStyle(PlainButtonStyle())
                    
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
                .fill(Color.nomadLightBlue)
                .shadow(radius: 5)
        )
        .padding()
        .overlay(
            ZStack {
                if isExpanded {                    
                    AsyncImage(url: URL(string: image)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: isExpanded ? 200 : 80, height: isExpanded ? 150 : 60)
                            .cornerRadius(10)
                            .shadow(radius: 10)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isExpanded.toggle()
                                }
                            }
                    } placeholder: {
                        ProgressView()
                            .frame(width: 300, height: 250)
                    }
                    .transition(.scale(scale: 0.5, anchor: .center))
                }
            }
        )
    }
}


#Preview {
    POIDetailView(name: "Speedway", address: "5 XYZ St, Atlanta, GA 06843", distance: 4.5, phoneNumber: "+19055759875", image: "https://s3-media2.fl.yelpcdn.com/bphoto/xU26QLcW8XAohg_APoojdQ/o.jpg", rating: 4.5, price: "$$", time: 4.2, latitude: 35.0, longitude: 34.0, city: "adsfsad", vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")), aiVM: AIAssistantViewModel(), addStop: { poi in
        print(poi.name)
    })
}
