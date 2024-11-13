////
////  POIDetailView.swift
////  Nomad
////
////  Created by Connor on 10/17/24.
////
import SwiftUI

struct POIDetailView: View {
    @State private var isExpanded = false
    
    var name = "Speedway"
    var address = "901 Gas Station Avenue, Duluth GA"
    var distance = "in 30 mi"
    var phoneNumber = "4044315072"
    var image = "https://s3-media2.fl.yelpcdn.com/bphoto/xU26QLcW8XAohg_APoojdQ/o.jpg"
    
    var body: some View {
        ZStack {
            VStack(spacing: 10) {
                // Top part: Image and POI Information
                HStack(alignment: .top, spacing: 10) {
                    Button(action: {
                        withAnimation {
                            isExpanded.toggle()
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
                    .buttonStyle(PlainButtonStyle()) // Removes any default button styling
                        
                    // POI Information
                    VStack(alignment: .leading, spacing: 5) {
                        Text(name)
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text(address)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        
                        HStack {
                            Spacer() // Push stars to the center
                            HStack(spacing: 4) {
                                ForEach(0..<5) { _ in
                                    Image(systemName: "star")
                                }
                            }
                            Spacer() // Keep stars centered
                        }
                        
                        // Phone Button
                        Button(action: {
                            if let phoneURL = URL(string: "tel://\(phoneNumber)") {
                                UIApplication.shared.open(phoneURL)
                            }
                        }) {
                            Text(phoneNumber)
                                .foregroundColor(.blue)
                                .underline()
                        }
                    }
                    
                    // Time Information
                    VStack {
                        Text("+ 2 min")
                            .font(.headline)
                        Text(distance)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                
                Divider()
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
    }
}

struct ContentView: View {
    var body: some View {
        POIDetailView()
    }
}

#Preview {
    POIDetailView()
}
