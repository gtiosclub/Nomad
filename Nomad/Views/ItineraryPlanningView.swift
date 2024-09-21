//
//  ItineraryPlanningView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import SwiftUI

struct ItineraryPlanningView: View {
    @State var showText: Bool = false
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        Button("Start Planning") {
            showText = true
        }
        showText ? Text("Let's Go!!") : Text("")
    }
}

#Preview {
    ItineraryPlanningView()
}
