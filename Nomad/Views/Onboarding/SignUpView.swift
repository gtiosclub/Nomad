//
//  SignUpView.swift
//  Nomad
//
//  Created by Datta Kansal on 10/1/24.
//

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
    private let screenWidth = UIScreen.main.bounds.size.width
    private let screenHeight = UIScreen.main.bounds.size.height
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Image("") // Background Image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: screenWidth, height: screenHeight / 4)
                        .padding(.top, -8)
                    Image("") // Title Image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: screenWidth * 2 / 3, height: screenHeight / 5)
                }
                
                Text("Create Account")
                    .font(Font.custom("Quicksand-Medium", size: 32))
                    .foregroundColor(Color.gray)
                    .padding(36)

                VStack(spacing: 15) {
                    HStack {
                        Text("Email Address")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 16))
                            .padding(.bottom, -5)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "envelope")
                            .resizable()
                            .frame(width: 21, height: 17)
                            .padding([.leading, .trailing], 16)
                        TextField("", text: $email, prompt: Text("Email Address").foregroundColor(Color.gray))
                            .foregroundColor(.black)
                            .textInputAutocapitalization(.never)
                            .textContentType(.emailAddress)
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(14)
                    .padding(.bottom, 15)
                    
                    HStack {
                        Text("Password")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 16))
                            .padding(.bottom, -5)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "lock")
                            .resizable()
                            .frame(width: 15, height: 17)
                            .padding([.leading, .trailing], 19)
                        SecureField("", text: $password, prompt: Text("Password").foregroundColor(Color.gray))
                            .textInputAutocapitalization(.never)
                            .textContentType(.newPassword)
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(14)
                    .padding(.bottom, 15)
                    
                    HStack {
                        Text("Confirm Password")
                            .foregroundColor(Color.gray)
                            .font(.system(size: 16))
                            .padding(.bottom, -5)
                        Spacer()
                    }
                    
                    HStack {
                        Image(systemName: "lock")
                            .resizable()
                            .frame(width: 15, height: 17)
                            .padding([.leading, .trailing], 19)
                        SecureField("", text: $repeatPassword, prompt: Text("Confirm Password").foregroundColor(Color.gray))
                            .textInputAutocapitalization(.never)
                            .textContentType(.newPassword)
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(14)
                    
                    if let errorText = vm.errorText {
                        Text(errorText)
                            .foregroundColor(.red)
                            .font(.footnote)
                    } else {
                        Text(" ")
                    }

                    Button(action: signUp) {
                        Text("Sign Up")
                            .foregroundColor(.black)
                            .font(.system(size: 19))
                            .frame(maxWidth: .infinity, minHeight: 45)
                            .background(Color.orange)
                            .cornerRadius(60)
                    }
                }
                .padding([.leading, .trailing], 20)
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer()

                HStack {
                    Text("Already have an account?")
                        .foregroundColor(Color.gray)
                    Spacer()
                    NavigationLink(destination: LogInView(vm: vm)) {
                        Text("Log In")
                            .foregroundColor(Color.gray)
                            .underline()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 25)
                .padding([.leading, .trailing], 57)
            }
            .ignoresSafeArea()
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
