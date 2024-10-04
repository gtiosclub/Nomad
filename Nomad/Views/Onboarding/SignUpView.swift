//
//  SignUpView.swift
//  Nomad
//
//  Created by Datta Kansal on 10/1/24.
//


import SwiftUI
struct SignUpView: View {
    @ObservedObject var vm: FirebaseViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var repeatPassword = ""
    @State private var navigateToHome = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Create Account")
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
                    
                    SecureField("Confirm Password", text: $repeatPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    if let errorText = vm.errorText {
                        Text(errorText)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                    
                    Button(action: signUp) {
                        Text("Sign Up")
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
                    Text("Already have an account?")
                    NavigationLink("Log In", destination: LogInView(vm: vm))
                }
                .font(.footnote)
                .padding(.bottom)
            }
            .navigationBarHidden(true)
        }
    }
    
    private func signUp() {
        vm.errorText = nil
        guard !email.isEmpty && !password.isEmpty && !repeatPassword.isEmpty else {
            vm.errorText = "Please fill in all fields"
            return
        }
        
        guard password == repeatPassword else {
            vm.errorText = "Passwords do not match"
            return
        }
        
        vm.firebase_email_password_sign_up(email: email, password: password) { success in
            if success {
                navigateToHome = true
            }
        }
    }
}

#Preview {
    SignUpView(vm: FirebaseViewModel())
}

