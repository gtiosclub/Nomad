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
//struct SignUpView: View {
//    @ObservedObject var vm: FirebaseViewModel
//    @State private var email: String = ""
//    @State private var password: String = ""
//    @State private var repeatPassword = ""
//    private let screenWidth = UIScreen.main.bounds.size.width
//    private let screenHeight = UIScreen.main.bounds.size.height
//    @State var navigateToHome: Bool = false
//    
//    var body: some View {
//        NavigationStack {
//            VStack {
//                Spacer()
//                
//                Text("Create Account")
//                    .font(Font.custom("Quicksand-Medium", size: 32))
//                    .foregroundColor(.brown)
//                    .padding(25)
//                
//                VStack{
//                
//                    HStack{
//                        Text("Email Address")
//                            .foregroundColor(.gray)
//                            .font(.system(size: 16))
//                            .padding(.bottom, -5)
//                        Spacer()
//                    }
//                    HStack{
//                        TextField("", text: $email, prompt: Text("Email Address")                .foregroundColor(.gray)).foregroundColor(.black)
//                            .textInputAutocapitalization(.never)
//                            .textContentType(.emailAddress)
//                    }
//                    .frame(maxWidth: .infinity, minHeight:52)
//                    .background(Color.gray)
//                    .clipShape(.rect(cornerRadius: 14.0))
//                    .padding(.bottom, 10)
//                    
//                    HStack{
//                        Text("Password")
//                            .foregroundColor(.gray)
//                            .font(.system(size: 16))
//                            .padding(.bottom, -5)
//                        Spacer()
//                    }
//                    
//                    HStack{
//                        Image("Lock")
//                            .resizable()
//                            .frame(width:15, height:17)
//                            .padding([.leading, .trailing], 19)
//                        SecureField("", text: $password, prompt: Text("Password")                .foregroundColor(.gray))
//                            .textInputAutocapitalization(.never)
//                            .textContentType(.newPassword)
//                    }
//                    .frame(maxWidth: .infinity, minHeight:52)
//                    .background(Color.gray)
//                    .clipShape(.rect(cornerRadius: 14.0))
//                    .padding(.bottom, 10)
//                    
//                    HStack{
//                        Text("Confirm Password")
//                            .foregroundColor(.gray)
//                            .font(.system(size: 16))
//                            .padding(.bottom, -5)
//                        Spacer()
//                    }
//                    
//                    HStack{
//                        Image("Lock")
//                            .resizable()
//                            .frame(width:15, height:17)
//                            .padding([.leading, .trailing], 19)
//                        SecureField("", text: $repeatPassword, prompt: Text("Confirm Password") .foregroundColor(.gray))
//                            .textInputAutocapitalization(.never)
//                            .textContentType(.newPassword)
//                    }
//                    .frame(maxWidth: .infinity, minHeight:52)
//                    .background(Color.gray)
//                    .clipShape(.rect(cornerRadius: 14.0))
//                    
//                    
//                    if let errorText = vm.errorText {
//                        Text(errorText).foregroundStyle(Color.red)
//                    } else {
//                        Text(" ")
//                    }
//                    
//                    Button{
//                        vm.errorText = nil
//                        email = email.trimmingCharacters(in: .whitespacesAndNewlines)
//                        password = password.trimmingCharacters(in: .whitespacesAndNewlines)
//                        
//                        if !email.isEmpty &&  !password.isEmpty && password == repeatPassword {
//                            vm.firebase_email_password_sign_up(
//                                email: self.email,
//                                password: self.password
//                            ) { completed in
//                                navigateToHome = completed
//                            }
//                        }
//                        else {
//                            vm.errorText = "You must fill out all fields"
//                        }
//                    } label: {
//                        Text("Sign Up")
//                            .foregroundColor(.black)
//                            .font(.system(size: 19))
//                    }
//                    .frame(maxWidth: .infinity, minHeight:45)
//                    .background(Color.orange)
//                    .clipShape(.rect(cornerRadius: 60))
//                    
//                }
//                .padding([.leading, .trailing], 20)
//                .frame(maxWidth: .infinity, alignment: .leading)
//                
//                Spacer(minLength: 40)
//                
//                HStack{
//                    Text("Already have an account?")
//                        .foregroundStyle(Color.gray)
//                    Spacer()
//                    NavigationLink{
//                        LogInView(vm: vm)
//                            .navigationBarBackButtonHidden(true)
//                    } label: {
//                        Text("Log In")
//                            .foregroundStyle(Color.gray)
//                            .underline()
//                    }
//                }
//                .frame(maxWidth: .infinity)
//                .padding(.bottom, 25)
//                .padding([.leading, .trailing], 57)
//            }
//            .ignoresSafeArea()
//        }
//    }
//}

#Preview {
    SignUpView(vm: FirebaseViewModel())
}

