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
            GeometryReader { geo in
                ZStack {
                    Circle()
                        .foregroundStyle(Color.nomadDarkBlue)
                    Image(systemName: "location.north.fill")
                        .font(.system(size: geo.size.width*0.45))
                        .foregroundStyle(Color.white)
                }
            }
        }
    }
}

#Preview {
    @Previewable var reset: () -> Void = { print("pressed") }
    RecenterMapView(recenterMap: reset)
        .frame(width: 200, height: 200)
}
