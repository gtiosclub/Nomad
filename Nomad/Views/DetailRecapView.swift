//
//  DetailRecapView.swift
//  Nomad
//
//  Created by Shaunak Karnik on 10/3/24.
//

import SwiftUI
import PhotosUI

struct DetailRecapView: View {
    @State var selectedItems: [PhotosPickerItem] = []
    @ObservedObject var vm: UserViewModel
    @State var trip: Trip
    @State var images: [UIImage] = []
    @State var routePlanned: Bool = false
    
    var body: some View {
        ScrollView {
            
        }
        .onChange(of: routePlanned) {}
    }
}



#Preview {
    DetailRecapView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville", coverImageURL: "https://pixabay.com/get/g396fa4b9bb9c1731092f12dcf2bb686fc52caaa5dc7a6f7a9edafe2c402bfe67b1a3affcdae0731b43338a151f0d3b21_640.jpg"), Trip(start_location: Activity(address: "123 Start St", name: "Scenic California Mountain Route", latitude: 34.0522, longitude: -118.2437, city: "Boston"), end_location: Hotel(address: "456 End Ave", name: "End Hotel", latitude: 34.0522, longitude: -118.2437, city: "Seattle"), name: "Cross Country", coverImageURL: "https://pixabay.com/get/g1a5413e9933d659796d14abf3640f03304a18c6867d6a64987aa896e3b6ac83ccc2ac1e5a4a2a7697a92161d1487186b7e2b6d4c17e0f11906a0098eef1da812_640.jpg"), Trip(start_location: Activity(address: "789 Another St", name: "Johnson Family Spring Retreat", latitude: 34.0522, longitude: -118.2437, city: "Los Angeles"), end_location: Hotel(address: "123 Another Ave", name: "Another Hotel", latitude: 34.0522, longitude: -118.2437, city: "Blue Ridge"), name: "GA Mountains", coverImageURL: "https://pixabay.com/get/gceb5f3134c78efcc8fbd206f7fb8520990df3bb7096474f685f8c3cb95749647d5f4752db8cf1521e69fa27b940044b7f477dd18e51de093dd7f79b833ceca1b_640.jpg")])), trip: Trip(start_location: Restaurant(address: "848 Spring Street, Atlanta GA 30308", name: "Tiff's Cookies", rating: 4.5, price: 1, latitude: 33.778033, longitude: -84.389090), end_location: Hotel(address: "201 8th Ave S, Nashville, TN  37203 United States", name: "JW Marriott", latitude: 36.156627, longitude: -86.780947), start_date: "10-05-2024", end_date: "10-05-2024", stops: [Activity(address: "1720 S Scenic Hwy, Chattanooga, TN  37409 United States", name: "Ruby Falls", latitude: 35.018901, longitude: -85.339367)], name: "ATL to Nashville", coverImageURL: "https://pixabay.com/get/g396fa4b9bb9c1731092f12dcf2bb686fc52caaa5dc7a6f7a9edafe2c402bfe67b1a3affcdae0731b43338a151f0d3b21_640.jpg"))
}
