//
//  NomadApp.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import SwiftUI
import SwiftData
import Firebase
import FirebaseAuth
import FirebaseCore
import FirebaseAppCheck


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct YourApp: App {

  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      NavigationView {
          RootView()
      }
    }
  }
}
