//
//  SplashView.swift
//  Nomad
//
//  Created by Datta Kansal on 11/16/24.
//
import SwiftUI

struct SplashView: View {
    @ObservedObject var firebaseViewModel: FirebaseViewModel
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            VStack {
                if firebaseViewModel.current_user != nil {
                    RootView(vm: UserViewModel(user: firebaseViewModel.current_user!))
                        .toolbar(.hidden, for: .navigationBar)
                } else {
                    SignUpView(vm: firebaseViewModel)
                }
            }
        } else {
            VStack {
                Image("AtlasIcon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if let user = firebaseViewModel.auth.currentUser {
                        Task {
                            _ = await firebaseViewModel.setCurrentUser(userId: user.displayName ?? "")
                        }
                    }
                    isActive = true
                }
            }
        }
    }
}

