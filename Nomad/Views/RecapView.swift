//
//  RecapView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct RecapView: View {
    var body: some View {
        VStack {
            HStack {
                Text("Let's see where you've been!")
                    .font(.system(size: 18, weight: .bold))
                Spacer()
            }.padding(20)
            HStack {
                Text("Favorites")
                Spacer()
            }.padding(.leading, 20)
            ScrollView (.horizontal) {
                HStack {
                    CardView(name: "Scenic California Mountain Route")
                    CardView(name: "Johnson Family Spring Retreat")
                    CardView()
                }
            }.padding(.leading, 20)
            Spacer()
        }
    }
}

struct CardView: View {
    var name: String = "default name"
    var duration: String = "default duration"
    var tags: [String] = []
    
    var body: some View {
        // fix changing heights with different name length
        VStack (alignment: .leading) {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(.gray)
                .frame(width: 180, height: 150)
            VStack {
                Text(name)
                HStack {
                    // tags
                }
            }.padding(.horizontal, 7)
        }.frame(width: 180, height: 200)
    }
}
#Preview {
    RecapView()
}
