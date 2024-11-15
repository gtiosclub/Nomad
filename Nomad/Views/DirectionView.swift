//
//  DirectionView.swift
//  Nomad
//
//  Created by Nicholas Candello on 10/23/24.
//
import SwiftUI
import MapboxDirections
import CoreLocation

struct HighwayBox: View {
    var exitNumber: Int?
    var body: some View {
        ZStack {
            Image(systemName: "shield.fill")
                .foregroundStyle(Color.black)
                .font(.system(size: 67))
            Image(systemName: "shield.fill")
                .foregroundStyle(Color.nomadDarkBlue)
                .font(.system(size: 60))
                
            if let number = exitNumber {
                Text("\(number)")
                    .font(.system(size: 25))
                    .bold()
                    .foregroundStyle(.white)
            }
        }
    }
}

struct DirectionView: View {
    var step: NomadStep
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                VStack(spacing: 20) {
                    getStepIcon(type: step.direction.maneuverType, direction: step.direction.maneuverDirection)
                        .font(.system(size: 40))
                    Text("\(getDistanceDescriptor(meters: step.direction.distance)[0]) ")
                        .font(.title2).bold() + Text("\(getDistanceDescriptor(meters: step.direction.distance)[1])")
                        .font(.title3)
                }
                if showHighwayIcon() {
                    HighwayBox(exitNumber : step.direction.exitIndex)
                    
                }
                VStack(alignment: .leading) {
                    Text(formattedInstructions())
                        .lineLimit(2)
                        .bold()
                        .font(.system(size: showHighwayIcon() ? 30 : 40))
                    if let formattedSubInstructions = formattedSubIntructions() {
                        Text(formattedSubInstructions)
                            .lineLimit(1)
                            .font(.system(size: 15))
                    }
                }.frame(maxWidth: .infinity)

            }
            .padding(25)
            .background(Color.nomadLightBlue)
            .cornerRadius(10)
        }
    }
    
    func showHighwayIcon() -> Bool {
        if step.direction.maneuverType != .turn {
            return true
        } else {
            return false
        }
    }
    
    func getDistanceDescriptor(meters: Double) -> [String] {
        var strs = [String]()
        let miles = meters / 1609.34
        let feet = miles * 5280
        
        if feet < 800 {
            strs.append(String(format: "%d", Int(feet / 100) * 100)) // round feet to nearest 100 ft
            strs.append("ft")
            
        } else {
            strs.append(String(format: "%.1f", miles)) // round miles to nearest 0.1 mi
            strs.append("mi")
        }
        return strs
    }
    
    func getStepIcon(type maneuverType: ManeuverType, direction maneuverDirection: ManeuverDirection?) -> Image {
        if maneuverType == .turn {
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
        } else if maneuverType == .merge {
            return Image(systemName: "arrow.merge")
        } else {
            return Image(systemName: "car.fill")
        }
    }
    func formattedInstructions() -> String {
        let maneuverType = step.direction.maneuverType
        
        if maneuverType == .turn {
            return step.direction.names?.last ?? step.direction.instructions
        } else if maneuverType == .merge {
            return "Exit \(step.direction.exitCodes![0])"
        } else {
            return step.direction.instructions
        }
    }
    func formattedSubIntructions() -> String? {
        if showHighwayIcon() {
            return step.direction.names?.last ?? step.direction.instructions
        } else {
            return nil
        }
    }
}

#Preview {
    let distance = 200 // in m
    let instructions = "Turn left onto 5th St"
    let time = 60 // in s
    let fromStreet = "Peachtree St NW"
    let toStreet = "I-75 NW"
    let exitCodes = ["59b"]
    let exitIndex = 75
    let maneuverDirection = ManeuverDirection.right
    let maneuverType = ManeuverType.turn
    let direction = NomadStep.Direction(distance: CLLocationDistance(distance), instructions: instructions, expectedTravelTime: TimeInterval(time), exitCodes: exitCodes, exitIndex: exitIndex, instructionsDisplayedAlongStep: nil, maneuverDirection: maneuverDirection, maneuverType: maneuverType, intersections: nil, names: [fromStreet, toStreet])
    
    DirectionView(step: NomadStep(direction: direction))
        .padding(20)
}
