//
//  LoginView.swift
//  Nomad
//
//  Created by Datta Kansal on 10/1/24.
//

import SwiftUI

struct LogInView: View {
    @ObservedObject var vm: FirebaseViewModel
    @State var isChecked = false
    @State var email = ""
    @State var password = ""
    private let screenWidth = UIScreen.main.bounds.size.width
    private let screenHeight = UIScreen.main.bounds.size.height
    @State var navigateToHome: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack {
                ZStack {
                    Image("")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: screenWidth, height: screenHeight / 4)
                        .padding(.top, -8)
                    Image("")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: screenWidth * 2 / 3, height: screenHeight / 5)
                }
                
                Text("Sign In")
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
                            .textContentType(.password)
                    }
                    .frame(maxWidth: .infinity, minHeight: 52)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(14)
                    
                    if let errorText = vm.errorText {
                        Text(errorText)
                            .foregroundColor(.red)
                    } else {
                        Text(" ")
                    }
                    
                    Button(action: signIn) {
                        Text("Login")
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
                    Text("Don't have an account?")
                        .foregroundColor(Color.gray)
                    Spacer()
                    NavigationLink(destination: SignUpView(vm: vm).navigationBarBackButtonHidden(true)) {
                        Text("Sign Up")
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
    
    private func signIn() {
        vm.errorText = nil
        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !email.isEmpty && !password.isEmpty {
            vm.firebase_email_password_sign_in(email: email, password: password) { success in
                if success {
                    navigateToHome = true
                }
                
            }
        } else {
            vm.errorText = "You must fill out all fields"
        }
    }
}

#Preview {
    LogInView(vm: FirebaseViewModel())
}
