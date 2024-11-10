//
//  AtlasLoadingView.swift
//  Nomad
//
//  Created by Rik Roy on 11/8/24.
//

import SwiftUI

//
//  SpinningCircularOutline.swift
//  Nomad
//
//  Created by Rik Roy on 11/8/24.
//


import SwiftUI

struct AtlasLoadingView: View {
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background circle (static)
            
            GIFImageView("AtlasAnimation")
                .frame(width: 140, height: 140)
            Circle()
                .stroke(lineWidth: 10.0)
                .opacity(0.3)
                .foregroundColor(.blue)
                .frame(width: 100, height: 100)
            
//            Image("AtlasIcon")
//                .resizable()
//                .frame(width: 50, height: 50)
    
            
            // Spinning circle (outline)
            Circle()
                .stroke(
                    AngularGradient(gradient: Gradient(colors: [.blue, .purple]), center: .center),
                    style: StrokeStyle(lineWidth: 10.0, lineCap: .round)
                )
                .rotationEffect(Angle(degrees: rotation))
                .animation(
                    .linear(duration: 2)
                    .repeatForever(autoreverses: false),
                    value: rotation
                )
                .frame(width: 100, height: 100)
        }
        .onAppear {
            // Start spinning animation when the view appears
            rotation = 360
        }
    }
}

#Preview {
    AtlasLoadingView()
}
