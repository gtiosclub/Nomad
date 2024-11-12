//
//  RatingFilterView.swift
//  Nomad
//
//  Created by Neel Bhattacharyya on 10/31/24.
//

import SwiftUI

struct RatingFilterView: View {
    @Binding var selectedRating: Int
    
    let ratings = ["1 ★", "2 ★", "3 ★", "4 ★", "5 ★"]
    
    @Binding var isRatingDropdownOpen: Bool
    
    var body: some View {
        dropdownNum(
            title: "Rating",
            options: ratings,
            selectedOption: $selectedRating,
            isOpen: $isRatingDropdownOpen
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
            } .foregroundColor(.black)

            if isOpen.wrappedValue {
                VStack(alignment: .leading) {
                    ForEach(0..<options.count, id: \.self) { index in
                        Button(action: {
                            selectedOption.wrappedValue = index
                            //isOpen.wrappedValue = false
                        }) {
                            Text(options[index])
                                .padding(2)
                                .frame(maxWidth: 60)
                                .background(selectedOption.wrappedValue == index ? Color.gray.opacity(0.3) : Color.clear)

                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                //.padding(.vertical, 5)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .shadow(radius: 5)
                .padding(.horizontal)
            }
        }
    }
}

#Preview {
    RatingFilterView(
        selectedRating: .constant(2),
        isRatingDropdownOpen: .constant(true)
    )

}
