//
//  Testing.swift
//  Nomad
//
//  Created by Brayden Huguenard on 10/4/24.
//

import SwiftUI

struct Testing: View {
    var body: some View {
        HStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 1))
                Image(systemName: "plus")
                    .foregroundColor(.gray)
                    .font(.system(size: 18))
                    .bold()
            }
            AsyncImage(url: URL(string: "https://www.google.com/imgres?q=image&imgurl=https%3A%2F%2Fletsenhance.io%2Fstatic%2F8f5e523ee6b2479e26ecc91b9c25261e%2F1015f%2FMainAfter.jpg&imgrefurl=https%3A%2F%2Fletsenhance.io%2F&docid=-t22bY2ix3gHaM&tbnid=tYmxDgFq4MrkJM&vet=12ahUKEwjV3JnhhvaIAxWV_8kDHdG7H6kQM3oECBwQAA..i&w=1280&h=720&hcb=2&ved=2ahUKEwjV3JnhhvaIAxWV_8kDHdG7H6kQM3oECBwQAA")) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 140, height: 140)
                    .cornerRadius(10)
                    .clipped()
            } placeholder: {
                ProgressView()
                    .frame(width: 140, height: 140)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Moes")
                    .font(.headline)
                    .lineLimit(1)
                
                HStack {
                    Text("Mexican •")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    Text(String(repeating: "$", count: 2))
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
                
                
                
                Text("Open")
                    .font(.body)
                    .foregroundColor(.green)
                
                Text("Rating: \(String(format: "%.2f", 4.2))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        
        }
    }
}

#Preview {
    Testing()
}
