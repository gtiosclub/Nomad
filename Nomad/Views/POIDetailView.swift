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
    var distance = 5.0
    var phoneNumber = "4044315072"
    var image = "https://s3-media2.fl.yelpcdn.com/bphoto/xU26QLcW8XAohg_APoojdQ/o.jpg"
    var rating = 3.7
    var price = "$$$"
    var time = 5.1
    
    
    var body: some View {
        VStack(spacing: 10) {
            // Top part: Image and POI Information
            HStack(alignment: .top, spacing: 10) {
                
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
    POIDetailView()
}
