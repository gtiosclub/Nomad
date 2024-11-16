//
//  CarPlaySceneDelgate.swift
//  Nomad
//
//  Created by Shaunak Karnik on 11/6/24.
//

//import CarPlay
//import SwiftUI


import UIKit
// CarPlay App Lifecycle

import CarPlay
import os.log
import SwiftUI

//class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
//    var interfaceController: CPInterfaceController?
//    let logger = Logger()
//
//    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene,
//            didConnect interfaceController: CPInterfaceController) {
//
//        self.interfaceController = interfaceController
//
//        let gridButton = CPGridButton(titleVariants: ["Albums"],
//                                      image: UIImage(systemName: "list.triangle")!)
//        { button in
//            interfaceController.pushTemplate(self.listTemplate(),
//                                             animated: true,
//                                             completion: nil)
//
//        }
//
//        let gridTemplate = CPGridTemplate(title: "Nomad", gridButtons:  [])
//
//        // SwiftC apparently requires the explicit inclusion of the completion parameter,
//        // otherwise it will throw a warning
//        interfaceController.setRootTemplate(gridTemplate,
//                                            animated: true,
//                                            completion: nil)
//    }
//
//    func listTemplate() -> CPListTemplate {
//        let item = CPListItem(text: "Rubber Soul", detailText: "The Beatles")
//        item.handler = { item, completion in
//
//            self.logger.info("Item selected")
//            completion()
//        }
//        let section = CPListSection(items: [item])
//        return CPListTemplate(title: "Albums", sections: [section])
//    }
//
//    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnectInterfaceController interfaceController: CPInterfaceController) {
//        self.interfaceController = nil
//    }
//}


class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    @ObservedObject var vm: UserViewModel = UserViewModel(user: User(id: "austinhuguenard", name: "Austin Huguenard"))
    @State var selectedTab = 2
    var carWindow: CPWindow?
    var interfaceController: CPInterfaceController?
    
    //var locationService: LocationService
    var mapTemplate: CPMapTemplate?
    
    // CarPlay connected
    func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController, to window: CPWindow) {
        print("🚙🚙🚙🚙🚙  Connected to CarPlay.")
        self.interfaceController = interfaceController
        
        initTemplates()
        
        window.rootViewController = UIHostingController(rootView: MapView(tabSelection: $selectedTab, vm: vm))
        self.carWindow = window
        self.carWindow?.isUserInteractionEnabled = true
        self.carWindow?.isMultipleTouchEnabled = true
        self.interfaceController?.setRootTemplate(self.mapTemplate!, animated: true, completion: {_, _ in })
    }
    
    // CarPlay disconnected
    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        print("🚙🚙🚙🚙🚙 Disconnected from CarPlay.")
        self.interfaceController = nil
    }
    

    private func initTemplates() {
        self.mapTemplate = CPMapTemplate()
        self.mapTemplate?.automaticallyHidesNavigationBar = true
        self.mapTemplate?.hidesButtonsWithNavigationBar = false
        
        // Create the button
        let atlasButton = CPMapButton { _ in
            // Button action
            print("clicked")
        }
        atlasButton.isHidden = false
        atlasButton.isEnabled = true
        atlasButton.image = UIImage(systemName: "mic.fill")
        
        // Set map buttons (these are different from bar buttons)
        self.mapTemplate?.mapButtons = [atlasButton]
    }
}
