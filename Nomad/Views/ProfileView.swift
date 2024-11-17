//
//  ProfileView.swift
//  Nomad
//
//  Created by Datta Kansal on 11/10/24.
//
import SwiftUI

struct ProfileView: View {
    @ObservedObject var vm: UserViewModel
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .frame(width: 150, height: 150)
                Text("\(vm.user.getName())")
                    .font(.title2)
                    .bold()
                Text("\(vm.user.email)")
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


//#Preview {
//    ProfileView(vm: UserViewModel(user: User(id: "previewUser", name: "Preview User")))
//}
