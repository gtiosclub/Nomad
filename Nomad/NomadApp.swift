////
////  NomadApp.swift
////  Nomad
////
////  Created by Nicholas Candello on 9/15/24.
////
//

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
                    RootView(vm: UserViewModel(user: firebaseViewModel.current_user!))
                } else {
                    SignUpView(vm: firebaseViewModel)
                }
            }
            .onAppear {
                firebaseViewModel.onSetupCompleted = { vm in
                    print("made it to firebase setup")
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
