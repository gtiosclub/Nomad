//
//  PriceFilterView.swift
//  Nomad
//
//  Created by Neel Bhattacharyya on 10/31/24.
//

import SwiftUI

struct PriceFilterView: View {
    @Binding var selectedPrice: Int

    let prices = ["$", "$$", "$$$", "$$$$"]

    @State private var isPriceDropdownOpen = false

    var body: some View {
        dropdownNum(
            title: "Price",
            options: prices,
            selectedOption: $selectedPrice,
            isOpen: $isPriceDropdownOpen
        )
        
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
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 10).stroke())
            }.foregroundColor(.black)

            if isOpen.wrappedValue {
                ScrollView {
                    VStack(alignment: .leading) {
                        ForEach(0..<options.count, id: \.self) { index in
                            Button(action: {
                                selectedOption.wrappedValue = index
                                isOpen.wrappedValue = false
                            }) {
                                Text(options[index])
                                    .padding(.vertical, 2)
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


#Preview {
    PriceFilterView(
        selectedPrice: .constant(1)
    )
}
