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

    @Binding var isCuisineDropdownOpen: Bool

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
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(cuisines, id: \.self) { cuisine in
                        Button(action: {
                            toggleCuisineSelection(cuisine)
                        }) {
                            Text(cuisine)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(6)
                            .background(selectedCuisine.contains(cuisine) ? Color.gray.opacity(0.3) : .white)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .cornerRadius(8)
                //.padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
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
        selectedCuisine: .constant(["Chinese"]),
        isCuisineDropdownOpen: .constant(true)
    )
}
