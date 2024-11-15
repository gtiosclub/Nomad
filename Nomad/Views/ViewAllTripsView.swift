//
//  ViewAllTripsView.swift
//  Nomad
//
//  Created by amber verma on 10/24/24.
//

import SwiftUI

struct ViewAllTripsView: View {
    @ObservedObject var vm: UserViewModel
    @State private var currentCity: String? = nil
    var header: String
    @State var trips: [Trip]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HStack {
                        Text(header)
                            .bold()
                            .font(.system(size: 20))
                            .padding(.horizontal)
                        
                        Spacer()
                        
                        // Profile picture
                        ZStack {
                            Ellipse()
                                .fill(Color.gray)
                                .frame(width: 40, height: 40)
                            Text((vm.user.getName()).prefix(1).uppercased())
                                .foregroundColor(.white)
                                .font(.system(size: 25))
                        }
                        .padding(.trailing)
                    }
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach(trips) { trip in
                            NavigationLink(destination: {
                                PreviewRouteView(vm: vm, trip: trip)
                            }, label: {
                                TripGridView(trip: trip)
                                    .frame(alignment: .top)
                            })
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    struct TripGridView: View {
        @StateObject var trip: Trip
        @State private var textWidth: CGFloat = 170
        
        var body: some View {
            VStack(alignment: .leading) {
                if trip.coverImageURL.isEmpty {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: max(textWidth, 140)) // Use the measured width
                        .frame(height: 120)
                        .cornerRadius(10)
                } else {
                    AsyncImage(url: URL(string: trip.coverImageURL)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: max(textWidth, 140)) // Use the measured width
                            .frame(height: 120)
                            .cornerRadius(10)
                            .shadow(color: .black.opacity(0.5), radius: 5, y: 3)
                    } placeholder: {
                        ProgressView()
                            .frame(width: max(textWidth, 140)) // Use the measured width
                            .frame(height: 120)
                            .cornerRadius(10)
                    }
                }
                
                VStack(alignment: .leading, spacing: 0) {
                    Text(trip.name.isEmpty ? "New Trip" : trip.name)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                        .font(.system(size: 16))
                        .foregroundStyle(.black)
                        .padding(.leading, 5)
                    
                    HStack(spacing: 1) {
                        Text(trip.getStartCity())
                            .foregroundStyle(.gray)
                            .font(.system(size: 12))
                        
                        HStack(spacing: 1) {
                            Circle()
                                .frame(width: 1, height: 1)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Rectangle()
                                .frame(width: 3, height: 1)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Rectangle()
                                .frame(width: 3, height: 1)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            Circle()
                                .frame(width: 1, height: 1)
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        
                        Text(trip.getEndCity())
                            .foregroundStyle(.gray)
                            .font(.system(size: 12))
                    }
                    .padding(.leading, 5)
                    .padding(.bottom, 5)
                    .padding(.trailing, 5)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    
                    Text("\(intToWords(trip.getStops().count)) \(trip.getStops().count == 1 ? "stop" : "stops")")
                        .font(.system(size: 12))
                        .padding(3)
                        .padding(.horizontal, 5)
                        .background(Color.nomadDarkBlue.opacity(0.5))
                        .cornerRadius(8)
                        .foregroundColor(.black.opacity(0.7))
                        .padding(.leading, 5)
                }
                .padding(.top, 1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 5)
            .padding(.horizontal, 5)
        }
        
        func intToWords(_ number: Int) -> String {
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            return formatter.string(from: NSNumber(value: number)) ?? ""
        }
    }
}

func getCityName(_ address: String) -> String {
    let addressSplit = address.split(separator: ",")
    if addressSplit.count > 1 {
        return addressSplit[1].trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
        return "City"
    }
}
    
//#Preview {
//    ViewAllTripsView(vm: UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard")))
//}

