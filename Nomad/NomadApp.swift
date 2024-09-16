//
//  NomadApp.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import SwiftUI
import SwiftData

@main
struct NomadApp: App {
    @ObservedObject var firebase_vm = FirebaseViewModel()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(firebase_vm)
        }
    }
}
