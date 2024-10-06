//
//  LoginView.swift
//  Nomad
//
//  Created by Datta Kansal on 10/1/24.
//

import SwiftUI

struct LogInView: View {
    @ObservedObject var vm: FirebaseViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.brown)
                    .padding(.top, 50)
                
                VStack(spacing: 15) {
                    TextField("Email Address", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if let errorText = vm.errorText {
                        Text(errorText)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    
                    Button(action: signIn) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(10)
                    }
                    .disabled(vm.isLoading)
                    .opacity(vm.isLoading ? 0.5 : 1)
                    .overlay(
                        Group {
                            if vm.isLoading {
                                ProgressView()
                            }
                        }
                    )
                }
                .padding(.horizontal)
                
                Spacer()
                
                HStack {
                    Text("Don't have an account?")
                    NavigationLink("Sign Up", destination: SignUpView(vm: vm))
                }
                .font(.footnote)
                .padding(.bottom)
            }
            .navigationBarHidden(true)
        }
    }
    
    private func signIn() {
        vm.errorText = nil
        guard !email.isEmpty && !password.isEmpty else {
            vm.errorText = "Please fill in all fields"
            return
        }
        
        vm.firebase_email_password_sign_in(email: email, password: password) { success in
            if success {
                navigateToHome = true
            }
        }
    }
}


#Preview {
    LogInView(vm: FirebaseViewModel())
}
