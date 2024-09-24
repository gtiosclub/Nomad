//
//  FindStopView.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/22/24.
//

import SwiftUI

struct FindStopView: View {
    @ObservedObject var vm: UserViewModel
    @State var selection: String = "Food and Drink"
    let stop_types = ["Food and Drink", "Activities", "Scenic", "Hotels", "Tours and Landmarks", "Entertainment"]
    var body: some View {
        HStack {
            Text("Filter Stop Type")
            VStack {
                Picker("Select a stop type", selection: $selection) {
                    ForEach(stop_types, id: \.self) {
                        Text($0)
                        
                        //if selected type is hotel
                        if (stop_types = "Hotels") {
                            //show rating
                            //create rating stars
                            HStack(spacing: 10) {
                                ForEach(1...5, id:\.self) { star in
                                    Image(systemName: star <= currentRating ? "star.fill" : "star")
                                        .font(.system(size: 30))
                                    .foregroundColor(.yellow)
                                    .scaledToFit()
                                    
                                    .onTapGesture {
                                        currentRating = star
                                    }
                               
                                }
                            }
                        }
                    }
                }
                .pickerStyle(.menu)
            }
        }
    }
}

#Preview {
    FindStopView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "123 5th Street", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"))])))
}
