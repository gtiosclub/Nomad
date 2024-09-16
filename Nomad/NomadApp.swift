//
//  NomadApp.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/12/24.
//

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
