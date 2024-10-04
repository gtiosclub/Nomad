//
//  RecenterMapView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/20/24.
//

import SwiftUI

struct RecenterMapView: View {
    var recenterMap: () -> Void
    var body: some View {
        Button {
            recenterMap()
        } label: {
            ZStack {
                Circle()
                    .foregroundStyle(.gray)
                Image(systemName: "location.north.circle")
                    .resizable()
                    .foregroundStyle(.black)
            }
        }
    }
}

#Preview {
    @Previewable var reset: () -> Void = { print("pressed") }
    RecenterMapView(recenterMap: reset)
        .frame(width: 200, height: 200)
}
