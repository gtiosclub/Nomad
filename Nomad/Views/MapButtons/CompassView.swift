//
//  CompassView.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/20/24.
//

import SwiftUI

struct CompassView: View {
    var bearing: Double
    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(.gray)
            Image("needle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .rotationEffect(.degrees(bearing))
        }
    }
    
}

#Preview {
    @Previewable @State var bear: Double = 0
    Text("Use slider to test compass.")
    Slider(value: $bear, in: -360...360)
    CompassView(bearing: bear)
        .frame(width: 200, height: 200)
}
