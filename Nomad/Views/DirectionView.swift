//
//  DirectionView.swift
//  Nomad
//
//  Created by Nicholas Candello on 10/23/24.
//
import SwiftUI

struct DirectionView: View {
    @Binding var step: NomadStep?
    
    var body: some View {
        if let routeStep = step {
            Text(routeStep.direction.instructions)
        } else {
            VStack {}
        }
    }
}

#Preview {
//    Task {
//        if let route = MapManager.manager.getExampleRoute() {
    DirectionView(step: Binding.constant(NomadStep()))
//    }
// }
}
