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
                    Text("Here are the places you stopped:")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.bottom, 10)
                    Spacer()
                }
                RoundedRectangle(cornerRadius: 10)
                    .stroke(.gray, lineWidth: 1)
                    .frame(width: .infinity, height: 400)
                    .padding(.bottom, 20)
                HStack {
                    Text("Visual road maps:")
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
    DetailRecapView(title: "California")
}
