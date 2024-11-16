//
//  BottomNavView.swift
//  Nomad
//
//  Created by Karen Lu on 11/12/24.
//
import SwiftUI
struct BottomNavView: View {
    var routeName: String
    var expectedTravelTime: TimeInterval // in s
    var distance: Double // in m
    
    var cancel: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack {
                    Text(calculateArrivalTime())
                    Text("arrival")
                        .foregroundStyle(Color.nomadDarkBlue)
                        .font(.caption)
                        
                }
                Spacer()
                VStack {
                    Text(formatTravelTime())
                    Text("hrs")
                        .foregroundStyle(Color.nomadDarkBlue)
                        .font(.caption)
                        
                }
                Spacer()
                VStack {
                    Text(formatMiles())
                    Text("mi")
                        .font(.caption)
                        .foregroundStyle(Color.nomadDarkBlue)
                }
                Spacer()
                Button(action: {
                    //action to end route
                    cancel()
                }) {
                    Text("End")
                        .font(.system(size: 20))
                        .bold()
                        .foregroundColor(.red)
                }
            }.font(.system(size: 30))
                .padding(.horizontal)
            
            Divider()
            
            Text(routeName)
                .font(.title)
                .padding(.bottom, 20)
        }
        .padding()
        .background(Color.nomadMediumBlue)
        .cornerRadius(20)
    }
    func calculateArrivalTime() -> String {
        let now = Date()
        let arrivalTime = now.addingTimeInterval(expectedTravelTime)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        
        return dateFormatter.string(from: arrivalTime)
    }
    
    func formatTravelTime() -> String {
        let hours = Int(expectedTravelTime / 3600)
        let minutes = Int((expectedTravelTime.truncatingRemainder(dividingBy: 3600)) / 60)
        
        
        return String(format: "%2d:%02d", hours, minutes)
    }
    
    func formatMiles() -> String {
        let miles = distance / 1609.34
        if miles >= 10 {
            return String(format: "%.0f", miles)
        } else {
            return String(format: "%.1f", miles)
        }
    }
}
