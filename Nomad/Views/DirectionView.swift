//
//  DirectionView.swift
//  Nomad
//
//  Created by Nicholas Candello on 10/23/24.
//
import SwiftUI
import MapboxDirections

struct HighwayBox: View {
    var imageName: String
    var exitNumber: Int?
    var body: some View {
        ZStack {
            Image(systemName: "\(imageName)")
                .font(.system(size: 45))
                .imageScale(.large)
                .foregroundStyle(.indigo)
            if let number = exitNumber {
                Text("\(number)")
                    .padding(5)
                    .background(Circle().fill(Color.white))
                    .foregroundColor(.indigo)
            }
        }
    }
}

struct DirectionView: View {
    var step: NomadStep
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    if let exitIndex = step.direction.exitIndex {
                        HighwayBox(imageName: "shield", exitNumber : exitIndex)
                    }
                    getStepIcon(for: step.direction.maneuverDirection)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.indigo)
                }
                VStack(alignment: .leading) {
                    Text(formattedInstructions())
                        .font(.title2)
                        .foregroundColor(.indigo)
                        .bold()
                        .padding(.bottom, 5)
                    Text("Distance: \(getDistanceDescriptor(meters: step.direction.distance))")
                        .font(.title3)
                        .foregroundColor(.indigo)
                }
            }
            .padding()
            .background(Color.gray)
            .cornerRadius(10)
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
    
    func getStepIcon(for maneuverDirection: ManeuverDirection?) -> Image {
        switch maneuverDirection {
        case.right:
            return Image(systemName: "arrow.turn.up.right")
        case.left:
            return Image(systemName: "arrow.turn.up.left")
        case.slightRight:
            return Image(systemName: "arrow.up.right")
        case.slightLeft:
            return Image(systemName: "arrow.up.left")
        case.straightAhead:
            return Image(systemName: "arrow.up")
        case.uTurn:
            return Image(systemName: "arrow.uturn.down")
        default:
            return Image(systemName: "car.fill")
        }
    }
    func formattedInstructions() -> String {
            var instruction = step.direction.instructions
            if let roadName = step.direction.names?.first {
                instruction += " onto \(roadName)"
            }
            return instruction
        }
}
//        if step.direction.instructions.lowercased().contains("right") {
//            return Image(systemName: "arrow.turn.up.right")
//        } else if step.direction.instructions.lowercased().contains("left") {
//            return Image(systemName: "arrow.turn.up.left")
//        } else if step.direction.instructions.lowercased().contains("merge") {
//            return Image(systemName: "arrow.merge")
//        } else {
//            return Image(systemName: "arrow.forward")
//        }

//    func getExitNumber(from instruction: String) -> Int? {
//        let pattern = #"exit (\d+)"#
//        let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
//        let range = NSRange(location: 0, length: instruction.utf16.count)
//        if let match = regex?.firstMatch(in: instruction, options: [], range: range),
//           let exitRange = Range(match.range(at: 1), in: instruction),
//           let exitNumber = Int(instruction[exitRange]) {
//            return exitNumber
//        }
//        return nil
//    }
//
//    func getExitIcon(for exitNumber: Int) -> some View {
//        ZStack {
//            Image(systemName: "road.lanes")
//                .resizable()
//                .frame(width: 40, height: 40)
//
//            Text("\(exitNumber)")
//                .font(.caption)
//                .bold()
//                .foregroundColor(.white)
//                .padding(2)
//                .background(Circle().fill(Color.indigo))
//                .offset(x: 10, y: -10)
//        }
//    }
//}
//
//enum StepType {
//    case leftTurn, rightTurn, slightLeft, slightRight, uturn, merge, exitLeft, exitRight
//
//    var icon: Image {
//        switch self {
//        case.leftTurn:
//            return Image(systemName: "arrow.turn.up.left")
//        case.rightTurn:
//            return Image(systemName: "arrow.turn.up.right")
//        case.slightLeft:
//            return Image(systemName: "arrow.up.left")
//        case.slightRight:
//            return Image(systemName: "arrow.up.right")
//        case.uturn:
//            return Image(systemName: "arrow.uturn.down")
//        case.merge:
//            return Image(systemName: "arrow.merge")
//        case.exitLeft:
//            return Image(systemName: "road.lanes.curved.left")
//        case.exitRight:
//            return Image(systemName: "road.lanes.curved.right")
//        }
//    }
//}

#Preview {
    DirectionView(step: NomadStep())
}
