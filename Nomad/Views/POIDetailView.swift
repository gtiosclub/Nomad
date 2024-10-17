//
//  POIDetailView.swift
//  Nomad
//
//  Created by Connor on 10/17/24.
//

import SwiftUI

struct POIDetailView: View {
    var body: some View {
        VStack(spacing: 10) {
            // Top part: Image and POI Information
            HStack(alignment: .top, spacing: 10) {
                // Image placeholder
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 80, height: 60)
                    .overlay(
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundColor(.black.opacity(0.6))
                            .padding([.trailing, .bottom], 8),
                        alignment: .bottomTrailing
                    )
                
                // POI Information
                VStack(alignment: .leading, spacing: 5) {
                    Text("Speedway")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("901 Gas Station Avenue, Duluth GA")
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
                }
                
                // Time Information
                VStack {
                    Text("+ 2 min")
                        .font(.headline)
                    Text("in 30 mi")
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

struct ContentView: View {
    var body: some View {
        POIDetailView()
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
