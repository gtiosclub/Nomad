//
//  POIDetailView.swift
//  Nomad
//
//  Created by Connor on 10/17/24.
//

import SwiftUI

struct POIDetailView: View {
    
    var name = "Speedway"
    var address = "901 Gas Station Avenue, Duluth GA"
    var distance = "in 30 mi"
    var phoneNumber = "4044315072"
    var image = "https://s3-media2.fl.yelpcdn.com/bphoto/xU26QLcW8XAohg_APoojdQ/o.jpg"
//    var rating = "3.4"
//    var price = ""
    
    
    var body: some View {
        VStack(spacing: 10) {
            // Top part: Image and POI Information
            HStack(alignment: .top, spacing: 10) {
                // Image placeholder
//                RoundedRectangle(cornerRadius: 10)
//                    .fill(Color.gray.opacity(0.2))
//                    .frame(width: 80, height: 60)
//                    .overlay(
//                        Image(systemName: "arrow.up.left.and.arrow.down.right")
//                            .resizable()
//                            .frame(width: 16, height: 16)
//                            .foregroundColor(.black.opacity(0.6))
//                            .padding([.trailing, .bottom], 8),
//                        alignment: .bottomTrailing
//                    )
                
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
            
            // Bottom part: Pricing
//            HStack {
//                Spacer()
//                Text("Reg. $3.04")
//                    .font(.headline)
//                Spacer()
//                Text("Mid. $3.39")
//                    .font(.headline)
//                Spacer()
//                Text("Plus $4.45")
//                    .font(.headline)
//                Spacer()
//            }
//            .padding(.bottom, 10)
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
    POIDetailView()
}
