//
//  DetailRecapView.swift
//  Nomad
//
//  Created by Shaunak Karnik on 10/3/24.
//

import SwiftUI
import PhotosUI

struct DetailRecapView: View {
    let title: String
    
    @State private var selectedDay = 1
    @State var selectedItems: [PhotosPickerItem] = []
    @State var recapImages: [Image] = []
    @ObservedObject var vm: UserViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    VStack (alignment: .leading){
                        Text(title)
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.bottom, 15)
                        PhotosPicker(selection: $selectedItems,
                                     matching: .any(of: [.images, .not(.screenshots)])) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(style: StrokeStyle(lineWidth: 1, dash: [2]))
                                    .frame(width: 200, height: 150)
                                Image(systemName: "plus.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30)
                            }.padding(.bottom, 30)
                        }
                        Text("Trip Details")
                            .font(.system(size: 18, weight: .semibold))
                            .padding(.bottom, 10)
                        HStack {
                            Image(systemName: "mappin")
                            Text("Los Angeles, CA")
                        }.padding(.bottom, 10)
                    }
                    Spacer()
                }
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(width: 155, height: 87)
                        VStack {
                            Text("428")
                                .font(.system(size: 30))
                            Text("miles traveled")
                        }
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(width: 155, height: 87)
                        VStack {
                            Text("51")
                                .font(.system(size: 30))
                            Text("hours spent")
                        }
                    }
                }.padding(.bottom, 40)
                HStack {
                    Text("Here are the places you stopped!")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.bottom, 10)
                    Spacer()
                }
                RoutePlanListView(vm: vm)
                    .padding(.bottom, 30)
                HStack {
                    Text("Here's how you moved around")
                        .font(.system(size: 18, weight: .semibold))
                    Spacer()
                }
                Picker("Select a day", selection: $selectedDay) {
                    Text("Day 1").tag(1)
                    Text("Day 2").tag(2)
                    Text("Day 3").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.bottom, 10)
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 1)
                        .frame(width: .infinity, height: 300)
                    Text("Day \(selectedDay)")
                }
                
                
            }.padding(.horizontal, 30)
                .padding(.bottom, 30)
        }
    }
}

#Preview {
    DetailRecapView(title: "California", vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"), stops: [Restaurant(address: "85 5th St. NW Atlanta, GA 30308", name: "Moes"), GeneralLocation(address: "630 10th St NW, Atlanta, GA 30318", name: "QuikTrip")])])))
}
