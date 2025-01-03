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
    @ObservedObject var navManager: NavigationManager
    var step: NomadStep
    
    private var maneuverType: ManeuverType?
    private var maneuverDirection: ManeuverDirection?
    private var text: String?
    
    // from components
    private var exitCode: String?
    private var image: String? // url to shield image
    private var streetName: String?
    private var delimiter: String?
    
    
    init(navManager: NavigationManager, step: NomadStep) {
        self.navManager = navManager
        self.step = step
        if let instruction = step.direction.instructionsDisplayedAlongStep?[0] {
            self.maneuverType = instruction.primaryInstruction.maneuverType
            self.maneuverDirection = instruction.primaryInstruction.maneuverDirection
            self.text = instruction.primaryInstruction.text
            for comp in instruction.primaryInstruction.components {
                switch comp {
                case .delimiter(let text):
                    self.delimiter = delimiter?.description
                case .text(let text):
                    self.streetName = text.text
                case .image(let image, let altText):
                    let url = image.imageURL(scale: 3, format: .png)?.absoluteString
                    print("URL: \(url)")
                    self.image = url
                case .exitCode(let text):
                    self.exitCode = text.text
                default:
                    continue
                }
            }
        }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 20) {
                VStack(spacing: 20) {
                    getStepIcon(type: maneuverType, direction: maneuverDirection)
                        .font(.system(size: 40))
                    Text("\(getDistanceDescriptor(meters: navManager.assignDistanceToNextManeuver())[0])")
                        .font(.title2).bold() + Text("\(getDistanceDescriptor(meters: navManager.assignDistanceToNextManeuver())[1])")
                        .font(.title3)
                }
                // highway exit
                if let url = URL(string: image ?? "") {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Image(systemName: "shield.fill")
                    }.frame(width: 70, height: 70)
                        
                }
                VStack(alignment: .leading) {
                    Text(text ?? formattedInstructions())
                        .lineLimit(2)
                        .bold()
                        .font(.system(size: image != nil ? 30 : 40))
                        .minimumScaleFactor(0.6)
                        .frame(width: 200)
//                    if let formattedSubInstructions = formattedSubIntructions() {
//                        Text(formattedSubInstructions)
//                            .lineLimit(1)
//                            .font(.system(size: 15))
//                    }
                }.frame(maxWidth: .infinity)

            }
            .padding(25)
            .background(Color.nomadMediumBlue)
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
            strs.append(String(format: "%d ", Int(feet / 100) * 100)) // round feet to nearest 100 ft
            strs.append("ft")
            
        } else {
            strs.append(String(format: "%.1f ", miles)) // round miles to nearest 0.1 mi
            strs.append("mi")
        }
        return strs
    }
    
    func getStepIcon(type maneuverType: ManeuverType?, direction maneuverDirection: ManeuverDirection?) -> Image {
        var manType: ManeuverType? = maneuverType
        var manDirection: ManeuverDirection? = maneuverDirection
        if let next_instruction = step.direction.instructionsDisplayedAlongStep?[0].primaryInstruction {
            if next_instruction.maneuverType != nil { manType = next_instruction.maneuverType! }
            manDirection = next_instruction.maneuverDirection
        }
        if manType == .turn {
            switch manDirection {
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
        } else if manType == .merge {
            return Image(systemName: "arrow.merge")
        } else if manType == .arrive {
            switch manDirection {
            case .left:
                return Image(systemName: "signpost.left")
            case .right:
                return Image(systemName: "signpost.right")
            default:
                return Image(systemName: "mappin.and.ellipse")
            }
        } else {
            return Image(systemName: "car.fill")
        }
    }
    
    func formattedInstructions() -> String {
        if step.direction.maneuverType == .turn {
            return step.direction.names?.last ?? step.direction.instructions
        } else if step.direction.maneuverType == .merge {
            return "Exit \(step.direction.exitCodes![0])"
        } else if step.direction.maneuverType == .arrive {
            let (curr, next) = navManager.getCurrentAndNextPOI()
            return "\(curr.name)"
        } else {
            return step.direction.instructions
        }
    }
    
//    func formattedSubIntructions() -> String? {
//        if showHighwayIcon() {
//            return step.direction.names!.last
//        } else {
//            return nil
//        }
//    }
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
    
    DirectionView(navManager: NavigationManager(), step: NomadStep(direction: direction))
        .padding(20)
}
