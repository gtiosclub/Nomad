//
//  CuisineFilterView.swift
//  Nomad
//
//  Created by Neel Bhattacharyya on 10/31/24.
//

import SwiftUI

struct CuisineFilterView: View {
    @Binding var selectedCuisine: [String]
    
    let cuisines = ["Chinese", "Italian", "Indian", "American", "Japanese", "Korean"]

    @State private var isCuisineDropdownOpen = false

    var body: some View {
        VStack(alignment: .leading) {
            Button(action: {
                isCuisineDropdownOpen.toggle()
            }) {
                HStack {
                    Text("Cuisine")
                    Spacer()
                    Image(systemName: isCuisineDropdownOpen ? "chevron.up" : "chevron.down")
                }
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 10).stroke())
            }.foregroundColor(.black)
            
            if isCuisineDropdownOpen {
                ScrollView {
                    VStack(alignment: .leading, spacing: 4) {
                        ForEach(cuisines, id: \.self) { cuisine in
                            Button(action: {
                                toggleCuisineSelection(cuisine)
                            }) {
                                HStack(alignment: .center) {
                                    Image(systemName: selectedCuisine.contains(cuisine) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(selectedCuisine.contains(cuisine) ? .blue : .gray)
                                    Text(cuisine)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .frame(height: 150)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .shadow(radius: 5)
                .padding(.horizontal)
            }
        }.padding()
    }
    private func toggleCuisineSelection(_ cuisine: String) {
        if selectedCuisine.contains(cuisine) {
            selectedCuisine.removeAll { $0 == cuisine }
        } else {
            selectedCuisine.append(cuisine)
        }
    }
}

#Preview {
    CuisineFilterView(
        selectedCuisine: .constant(["Chinese"])
    )
}
