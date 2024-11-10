//
//  DirectionView.swift
//  Nomad
//
//  Created by Karen Lu on 10/8/24.
//

import SwiftUI
import MapKit
import MapboxDirections

struct HighwayBox: View {
    var imageName: String
    var number: Int
    var body: some View {
        ZStack {
            Image(systemName: "\(imageName)")
                .font(.system(size: 40))
                .imageScale(.large)
                .foregroundStyle(.indigo)
            Text("\(number)")
                .padding(5)
        }
    }
}

struct DirectionView: View {
    var step: NomadStep
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    HighwayBox(imageName: "square", number: 123)
                    getStepIcon(step: step)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.indigo)
                }
                VStack(alignment: .leading) {
                    Text(step.direction.instructions)
                        .font(.title2)
                        .foregroundColor(.indigo)
                        .bold()
                        .padding(.bottom, 5)
                    Text("Distance: \(String(format: "%.2f", step.direction.distance)) meters")
                        .font(.title3)
                        .foregroundColor(.indigo)
                }
            }
            .padding()
            .background(Color.gray.opacity(0.3))
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background {
            Color.gray.opacity(0.5)
                .ignoresSafeArea()
        }
        
    }
    
    //    func getRouteStep(for route: NomadRoute, at stepIndex: Int) {
    //        guard stepIndex >= 0 && stepIndex < route.NomadRoute.count else {
    //            print("Invalid step index")
    //            return
    //        }
    //        let step = route.steps[stepIndex]
    //        self.step = step
    //    }
    
    func getStepIcon(step: NomadStep) -> Image {
        //        if step.direction.instructions.lowercased().contains("exit"),
        //           let exitNumber = getExitNumber(from: step.direction.instructions) {
        //            return getExitIcon(for: exitNumber)
        //        }
        if step.direction.instructions.lowercased().contains("right") {
            return Image(systemName: "arrow.turn.up.right")
        } else if step.direction.instructions.lowercased().contains("left") {
            return Image(systemName: "arrow.turn.up.left")
        } else if step.direction.instructions.lowercased().contains("merge") {
            return Image(systemName: "arrow.merge")
        } else {
            return Image(systemName: "arrow.forward")
        }
    }
    func getExitNumber(from instruction: String) -> Int? {
        let pattern = #"exit (\d+)"#
        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        let range = NSRange(location: 0, length: instruction.utf16.count)
        if let match = regex?.firstMatch(in: instruction, options: [], range: range),
           let exitRange = Range(match.range(at: 1), in: instruction),
           let exitNumber = Int(instruction[exitRange]) {
            return exitNumber
        }
        return nil
    }
    
    func getExitIcon(for exitNumber: Int) -> some View {
        ZStack {
            Image(systemName: "road.lanes")
                .resizable()
                .frame(width: 40, height: 40)
            
            Text("\(exitNumber)")
                .font(.caption)
                .bold()
                .foregroundColor(.white)
                .padding(2)
                .background(Circle().fill(Color.indigo))
                .offset(x: 10, y: -10)
        }
    }
}

enum StepType {
    case leftTurn, rightTurn, slightLeft, slightRight, uturn, merge, exitLeft, exitRight
    
    var icon: Image {
        switch self {
        case.leftTurn:
            return Image(systemName: "arrow.turn.up.left")
        case.rightTurn:
            return Image(systemName: "arrow.turn.up.right")
        case.slightLeft:
            return Image(systemName: "arrow.up.left")
        case.slightRight:
            return Image(systemName: "arrow.up.right")
        case.uturn:
            return Image(systemName: "arrow.uturn.down")
        case.merge:
            return Image(systemName: "arrow.merge")
        case.exitLeft:
            return Image(systemName: "road.lanes.curved.left")
        case.exitRight:
            return Image(systemName: "road.lanes.curved.right")
        }
    }
}

#Preview {
    DirectionView(step: NomadStep())
}
