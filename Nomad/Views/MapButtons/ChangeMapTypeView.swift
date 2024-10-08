//
//  ChangeMapTypeView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/20/24.
//

import MapKit
import SwiftUI

enum MapTypes {
    case defaultMap, satellite, terrain
}

struct ChangeMapTypeView: View {
    @Binding var selectedMapType: MapTypes
    var body: some View {
        HStack {
            VStack {
                Text("Default")
                Button {
                    selectedMapType = .defaultMap
                } label: {
                    Image("default_preview")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }.padding().background(selectedMapType == .defaultMap ? .blue : .clear).cornerRadius(10)
            VStack {
                Text("Satellite")
                Button {
                    selectedMapType = .satellite
                } label: {
                    Image("satellite_preview")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }.padding().background(selectedMapType == .satellite ? .blue : .clear).cornerRadius(10)
            VStack {
                Text("Terrain")
                Button {
                    selectedMapType = .terrain
                } label: {
                    Image("terrain_preview")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }.padding().background(selectedMapType == .terrain ? .blue : .clear).cornerRadius(10)
        }.padding()
    }
}
struct ChangeMapTypeButtonView: View {
    @State private var showMapTypeSheet: Bool = false
    @Binding var selectedMapType: MapTypes
    var body: some View {
        Button {
            showMapTypeSheet.toggle()
        } label: {
            ZStack {
                Circle().foregroundStyle(.gray)
                Image(systemName: "map.circle")
                    .resizable()
                    .foregroundStyle(.black)
            }
        }.sheet(isPresented: $showMapTypeSheet) {
            ChangeMapTypeView(selectedMapType: $selectedMapType)
                .presentationDetents([.fraction(0.3)])
                .presentationDragIndicator(.visible)
        }

    }
}

#Preview {
    @Previewable @State var selectedType: MapTypes = .satellite
    ChangeMapTypeButtonView(selectedMapType: $selectedType)
        .frame(width: 200, height: 200)
    
}
