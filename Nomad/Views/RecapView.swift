//
//  RecapView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct RecapView: View {
    var cards: [CardView] = [CardView(title: "Scenic California Mountain Route", attributes: ["4-6 Hours", "Pet-friendly"]), CardView(title: "Johnson Family Spring Retreat", attributes: ["0-1 Hours", "Scenic"]), CardView(title: "Scenic California Mountain Route", attributes: ["4-6 Hours", "Pet-friendly"])]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Let's see where you've been!")
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.bottom, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                let columns = [GridItem(.flexible(), spacing: 20), GridItem(.flexible(), spacing: 10)]
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(cards) { card in
                        NavigationLink {
                            DetailRecapView(title: card.title)
                        } label: {
                            card
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                Spacer()
            }.padding(20)
        }
    }
}

struct CardView: View, Identifiable {
    let id = UUID()
    let title: String
    let attributes: [String]

    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(width: 165, height: 135)
                .cornerRadius(10)

            Text(title)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 5)

            let columns = [GridItem(.flexible()), GridItem(.flexible())]
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(attributes, id: \.self) { attribute in
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 20)
                        .overlay(Text(attribute)
                                    .font(.caption2))
                }
            }
        }
    }
}

#Preview {
    RecapView()
}

