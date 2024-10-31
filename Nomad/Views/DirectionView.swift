//
//  DirectionView.swift
//  Nomad
//
//  Created by Nicholas Candello on 10/23/24.
//
import SwiftUI

struct DirectionView: View {
    @Binding var distance: Double?
    var nextStep: NomadStep?
    
    var body: some View {
        if let dist = distance, let nextStep = nextStep  {
            VStack {
                Text("\(nextStep.direction.instructions) in \(getDistanceDescriptor(meters: dist))")
                    .font(.title)
                    .padding(20)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
        } else {
            VStack {}
        }
    }
    func getDistanceDescriptor(meters: Double) -> String {
        let miles = meters / 1609.34
        let feet = miles * 5280
        if feet < 800 {
            return String(format: "%d ft", Int(feet / 100) * 100) // round feet to nearest 100 ft
        } else {
            return String(format: "%.1f mi", miles) // round miles to nearest 0.1 mi
        }
    }
}

#Preview {
//    Task {
//        if let route = MapManager.manager.getExampleRoute() {
    DirectionView(distance: Binding.constant(100.0), nextStep: NomadStep())
//    }
// }
}
