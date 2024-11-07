//
//  TestingView.swift
//  Nomad
//
//  Created by Alec Hance on 11/7/24.
//

import SwiftUI

struct TestingView: View {
    @State var vm: FirebaseViewModel
    @State var image: UIImage
    var body: some View {
        Button("Test") {
            print("clicked")
            vm.storeImageAndReturnURL(image: image, tripID: "public_trip_1")
        }
    }
}

#Preview {
    TestingView(vm: FirebaseViewModel(), image: UIImage(systemName: "face.smiling")!)
}
