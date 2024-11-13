//
//  ProfileView.swift
//  Nomad
//
//  Created by Datta Kansal on 11/10/24.
//
import SwiftUI

struct ProfileView: View {
    var body: some View {
//        Text("Hello World")
        NavigationView {
            VStack {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 150, height: 150)
                Text("Name")
                    .font(.title2)
                    .bold()
                Text("email")
                    .font(.title3)
                    
                Button {
                    Task {
                        FirebaseViewModel.vm.firebase_sign_out()
                    }
                } label: {
                    Text("Sign out")
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .padding()
                }
            }
        }
    }
}


#Preview {
    ProfileView()
}
