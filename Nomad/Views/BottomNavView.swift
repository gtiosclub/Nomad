//
//  BottomNavView.swift
//  Nomad
//
//  Created by Karen Lu on 11/12/24.
//

import SwiftUI

struct BottomNavView: View {
    var routeName = "Mount Rainier Trailhead"
    var arrivalTime = "12:31"
    var travelTime = "3:10"
    var distance = "279"
    var totalTime = "17:15"
    var totalDistance = "1,123"
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack {
                    Text(arrivalTime)
                        .font(.system(size: 30, weight: .bold))
                    Text("arrival")
                        .font(.caption)
                        .foregroundColor(.black)
                }
                Spacer()
                VStack {
                    Text(travelTime)
                        .font(.system(size: 30, weight: .bold))
                    Text("hrs")
                        .font(.caption)
                        .foregroundColor(.black)
                }
                Spacer()
                VStack {
                    Text(distance)
                        .font(.system(size: 30, weight: .bold))
                    Text("mi")
                        .font(.caption)
                        .foregroundColor(.black)
                }
                Spacer()
                Button(action: {
                    //action to end route
                }) {
                    Text("End")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(10)
                }
            }
            .padding()

            
            Text(routeName)
                .font(.title)
                .fontWeight(.bold)
                .padding(.vertical, 5)
            Divider()
            
            HStack {
                VStack {
                    Text(totalTime)
                        .font(.system(size: 30, weight: .bold))
                    Text("hrs")
                        .font(.caption)
                        .foregroundColor(.black)
                }
                Spacer()
                Text("Day Total")
                    .font(.title)
                    .fontWeight(.bold)
                Spacer()
                VStack {
                    Text(totalDistance)
                        .font(.system(size:30, weight: .bold))
                    Text("mi")
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
            .padding()
        }
        .background(Color.gray.opacity(0.3))
        .cornerRadius(15)
        .padding()
    }
}


//arrival time
//hours in this format HR:MINS
//miles
//End button
//EndDestination
//total time spent in this format HR:MINS
//total miles

#Preview {
    BottomNavView()
}
