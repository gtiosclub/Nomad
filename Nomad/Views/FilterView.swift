//
//  FilterView.swift
//  Nomad
//
//  Created by Neel Bhattacharyya on 10/24/24.
//


import SwiftUI

struct FilterView: View {
    @Binding var selectedRating: Int
    @Binding var selectedCuisine: [String]
    @Binding var selectedPrice: Int

    let ratings = ["1 ★ and up", "2 ★ and up", "3 ★ and up", "4 ★ and up", "5 ★ and up"]
    let cuisines = ["Chinese", "Italian", "Indian", "American", "Japanese", "Korean"]
    let prices = ["$", "$$", "$$$", "$$$$"]

    @State private var isRatingDropdownOpen = false
    @State private var isCuisineDropdownOpen = false
    @State private var isPriceDropdownOpen = false

    var body: some View {
        HStack(spacing: 20) {
            dropdownNum(
                title: "Rating",
                options: ratings,
                selectedOption: $selectedRating,
                isOpen: $isRatingDropdownOpen
            )

            dropdownNum(
                title: "Price",
                options: prices,
                selectedOption: $selectedPrice,
                isOpen: $isPriceDropdownOpen
            )

            VStack(alignment: .leading) {
                Button(action: {
                    isCuisineDropdownOpen.toggle()
                }) {
                    HStack {
                        Text("Cuisine")
                        Spacer()
                        Image(systemName: isCuisineDropdownOpen ? "chevron.up" : "chevron.down")
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke())
                }

                if isCuisineDropdownOpen {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(cuisines, id: \.self) { cuisine in
                                Button(action: {
                                    toggleCuisineSelection(cuisine)
                                }) {
                                    HStack {
                                        Image(systemName: selectedCuisine.contains(cuisine) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(selectedCuisine.contains(cuisine) ? .blue : .gray)
                                        Text(cuisine)
                                    }
                                    .padding(.vertical, 8)
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
            }
        }
        .padding()
    }

    private func toggleCuisineSelection(_ cuisine: String) {
        if selectedCuisine.contains(cuisine) {
            selectedCuisine.removeAll { $0 == cuisine }
        } else {
            selectedCuisine.append(cuisine)
        }
    }

    private func dropdownNum(title: String, options: [String], selectedOption: Binding<Int>, isOpen: Binding<Bool>) -> some View {
        VStack(alignment: .leading) {
            Button(action: {
                isOpen.wrappedValue.toggle()
            }) {
                HStack {
                    Text(title)
                    Spacer()
                    Image(systemName: isOpen.wrappedValue ? "chevron.up" : "chevron.down")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 10).stroke())
            }

            if isOpen.wrappedValue {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(0..<options.count, id: \.self) { index in
                            Button(action: {
                                selectedOption.wrappedValue = index
                                isOpen.wrappedValue = false 
                            }) {
                                Text(options[index])
                                    .padding(.vertical, 4)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding()
                }
                .frame(height: 150)
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 5)
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            selectedRating: .constant(2),
            selectedCuisine: .constant(["Chinese"]),
            selectedPrice: .constant(1)
        )
    }
}
