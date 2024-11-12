//
//  FilterDropdownView.swift
//  Nomad
//
//  Created by Austin Huguenard on 11/12/24.
//

import SwiftUI

struct FilterDropdownView: View {
    let title: String
    let options: [String]
    @Binding var selectedOptions: [String] // For multiple selections, like Cuisine
    @Binding var selectedOption: Int       // For single selections, like Rating or Price
    @Binding var isDropdownOpen: Bool
    let allowsMultipleSelection: Bool      // Toggle for single vs. multiple selection

    var body: some View {
        VStack(alignment: .leading) {
            // Main dropdown button
            Button(action: {
                withAnimation {
                    isDropdownOpen.toggle()
                }
            }) {
                HStack {
                    Text(selectedOptionTitle)
                    Spacer()
                    Image(systemName: isDropdownOpen ? "chevron.up" : "chevron.down")
                }
                .padding(6)
                .background(RoundedRectangle(cornerRadius: 10).stroke())
            }
            .foregroundColor(.black)

            // Overlay dropdown options if the dropdown is open
            if isDropdownOpen {
                VStack(alignment: .leading, spacing: 4) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(options, id: \.self) { option in
                                Button(action: {
                                    handleSelection(option: option)
                                }) {
                                    HStack {
                                        Text(option)
                                            .foregroundColor(.black)
                                        Spacer()
                                        if isSelected(option: option) {
                                            Image(systemName: "checkmark")
                                                .foregroundColor(.blue)
                                        }
                                    }
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(isSelected(option: option) ? Color.gray.opacity(0.3) : Color.clear)
                                    .cornerRadius(5)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(5)
                    }
                    .frame(maxHeight: min(CGFloat(options.count) * 44, 150))
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .shadow(radius: 5)
                }
                .padding(.top, 5) // Add a small padding to separate dropdown from the button
                .zIndex(1) // Ensures the dropdown is above other content
            }
        }
        .padding(.horizontal, 5)
    }

    // Determine what to display as the dropdown title based on selection state
    private var selectedOptionTitle: String {
        if allowsMultipleSelection {
            return selectedOptions.isEmpty ? title : selectedOptions.joined(separator: ", ")
        } else {
            return selectedOption == 0 ? title : options[selectedOption - 1]
        }
    }

    // Handle selection for both single and multiple selection modes
    private func handleSelection(option: String) {
        if allowsMultipleSelection {
            if selectedOptions.contains(option) {
                selectedOptions.removeAll { $0 == option }
            } else {
                selectedOptions.append(option)
            }
        } else {
            if let index = options.firstIndex(of: option) {
                selectedOption = index + 1
            }
            isDropdownOpen = false
        }
    }

    // Check if an option is selected
    private func isSelected(option: String) -> Bool {
        if allowsMultipleSelection {
            return selectedOptions.contains(option)
        } else {
            return selectedOption != 0 && options[selectedOption - 1] == option
        }
    }
}

#Preview {
    VStack {
        FilterDropdownView(
            title: "Cuisine",
            options: ["Chinese", "Italian", "Indian", "American", "Japanese", "Korean"],
            selectedOptions: .constant(["Chinese"]),
            selectedOption: .constant(0),
            isDropdownOpen: .constant(true),
            allowsMultipleSelection: true
        )

        FilterDropdownView(
            title: "Rating",
            options: ["1 ★", "2 ★", "3 ★", "4 ★", "5 ★"],
            selectedOptions: .constant([]),
            selectedOption: .constant(3),
            isDropdownOpen: .constant(false),
            allowsMultipleSelection: false
        )

        FilterDropdownView(
            title: "Price",
            options: ["$", "$$", "$$$", "$$$$"],
            selectedOptions: .constant([]),
            selectedOption: .constant(2),
            isDropdownOpen: .constant(false),
            allowsMultipleSelection: false
        )
    }
}
