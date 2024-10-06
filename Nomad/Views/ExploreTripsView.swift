//
//  ExploreTripsView.swift
//  Nomad
//
//  Created by Lingchen Xiao on 10/3/24.
//

import SwiftUI

struct ExploreTripsView: View {
    let user = User(id: "1", name: "John Howard")
    var body: some View {
        ScrollView {
            
            VStack (alignment: .leading) {
                HStack {
                    
                    Image(systemName: "mappin.and.ellipse")
                    Text("Los Angeles, CA")
                    Spacer()
                    
                }
                .padding(.horizontal)
                HStack {
                    Text("Plan your next trip, John!")
                        .bold()
                        .font(.system(size: 20))
                        .padding(.horizontal)
                        .padding(.top, 10)
                    Spacer()
                    
                    //profile picture
                    ZStack {
                        Ellipse()
                            .fill(Color.gray)
                            .frame(width: 50, height: 50)
                        Text(user.getName().prefix(1))
                            .foregroundColor(.white)
                            .font(.system(size: 30, weight: .bold))
                    }
                    .padding(.trailing)
                }
                
                //itineraries
                VStack(alignment: .leading) {

                    SectionHeaderView(title: "My itineraries")
                    HStack {
                        TripGridView(tripName: "Scenic California Mountain Route", tags:["4-6 hours","pet-friendly","scenic"])
                        TripGridView(tripName: "Johnson Family Spring Retreat", tags: ["0-1 hours", "family-friendly"])
                    }
                   
                    SectionHeaderView(title: "Previous Itineraries")
                    HStack {
                        TripGridView(tripName: "Scenic California Mountain Route", tags:["4-6 hours","pet-friendly","scenic"])
                        TripGridView(tripName: "Lorum ipsum Pebble Beach, CA", tags: ["0-1 hours", "family-friendly"])
                    }
                    
                    SectionHeaderView(title: "Community Favourites")
                    HStack {
                        
                    }
                   
                }
                
            }
        }
    }
}

struct SectionHeaderView: View {
    var title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .bold()
            Spacer()
            Button(action: {}) {
                Text("View all")
                    .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 5)
    }
}

struct TripGridView: View {
    var tripName: String
    var tags: [String]
    var body: some View {
        VStack {
            
            //images, for now placed with rectangles
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 120)
                .cornerRadius(10)
                
            VStack(alignment: .leading, spacing: 5) {
                Text(tripName+"\n")
                    .font(.headline)
                    .lineLimit(2)
    
                HStack {
                    ForEach(tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(5)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(7)
                    }
                }
            }
            Spacer()
        }
        .padding(.vertical, 5)
    }
    
}
#Preview {
    ExploreTripsView()
}

