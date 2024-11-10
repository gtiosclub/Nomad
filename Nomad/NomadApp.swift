////
////  NomadApp.swift
////  Nomad
////
////  Created by Nicholas Candello on 9/15/24.
////
//
//import Foundation
//import SwiftUI
//import SwiftData
//import Firebase
//import FirebaseAuth
//import FirebaseCore
//import FirebaseAppCheck
//import UIKit
//
//@main
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    var window: UIWindow?
//  func application(_ application: UIApplication,
//                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
//      let providerFactory = AppCheckDebugProviderFactory()
//      AppCheck.setAppCheckProviderFactory(providerFactory)
//      
//    FirebaseApp.configure()
//      
//      let window = UIWindow(frame: UIScreen.main.bounds)
//      self.window = window
//      window.makeKeyAndVisible()
//      
//      let vm = FirebaseViewModel()
//      vm.onSetupCompleted = { vm in
//          DispatchQueue.main.async {
//              let rootView = SignUpView(vm: vm)
//                window.rootViewController = UIHostingController(rootView: rootView)
//          }
//      }
//      
////      vm.setCurrentUser(userId: vm.auth.currentUser?.displayName ?? "") { _ in
////          vm.configure()
////      }
//      Task {
//          if let displayName = vm.auth.currentUser?.displayName {
//              _ = await vm.setCurrentUser(userId: displayName)
//          }
//          vm.configure()
//      }
//    return true
//  }
//}
//
//func applicationWillResignActive(_ application: UIApplication) {
//    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
//}
//
//func applicationDidEnterBackground(_ application: UIApplication) {
//    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//}
//
//func applicationWillEnterForeground(_ application: UIApplication) {
//    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
//}
//
//func applicationDidBecomeActive(_ application: UIApplication) {
//    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//}
//
////@main
////struct YourApp: App {
////
////  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
////
////  var body: some Scene {
////    WindowGroup {
////      NavigationView {
////          RootView()
////      }
////    }
////  }
////}

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseAppCheck

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        
        FirebaseApp.configure()
        
        let providerFactory = AppCheckDebugProviderFactory()
        AppCheck.setAppCheckProviderFactory(providerFactory)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Handle app going to the background (e.g., save data, pause tasks)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Handle background-related tasks, if necessary
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Refresh app state when returning to foreground
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks paused (or not started) when app was inactive
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Handle app termination, save data if necessary
    }
}

@main
struct YourApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var firebaseViewModel = FirebaseViewModel()

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if firebaseViewModel.current_user != nil {
                    // If a user is signed in, navigate to the main app view
                    SignUpView(vm: firebaseViewModel)
                } else {
                    // Show the sign-up or login view for new users
                    SignUpView(vm: firebaseViewModel)
                }
            }
            .onAppear {
                // Configure Firebase and set up the initial user data
                firebaseViewModel.onSetupCompleted = { vm in
                    DispatchQueue.main.async {
                        if let user = firebaseViewModel.auth.currentUser {
                            Task {
                                _ = await firebaseViewModel.setCurrentUser(userId: user.displayName ?? "")
                            }
                        }
                    }
                }
                firebaseViewModel.configure()
            }
        }
    }
}
