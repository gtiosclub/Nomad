//
//  TripView.swift
//  Nomad
//
//  Created by Austin Huguenard on 9/21/24.
//

import SwiftUI

struct TripView: View {
    @ObservedObject var vm: UserViewModel
    @State var trip: Trip?
    @State var startDate: String = ""
    @State var endDate: String = ""
    var body: some View {
        NavigationStack {
            Text("Edit Trip Details")
                .font(.title)
                .frame(width: UIScreen.main.bounds.width - 20, alignment: .topLeading)
                .onAppear {
                    vm.setCurrentTrip(trip: trip!)
                }
                
            Spacer(minLength: 20)
            
            Text("Your trip from \(vm.current_trip?.getStartLocation().name ?? "") to \(vm.current_trip?.getEndLocation().name ?? "")")
                .frame(width: UIScreen.main.bounds.width - 20, alignment: .topLeading)
            
            VStack {
                HStack {
                    Text(vm.current_trip?.getStartLocation().name ?? "")
                        .frame(alignment: .leading)
                    Spacer()
                    Text(vm.current_trip?.getStartLocation().address ?? "")
                        .frame(alignment: .trailing)
                }
                HStack {
                    Text(vm.current_trip?.getEndLocation().name ?? "")
                        .frame(alignment: .leading)
                    Spacer()
                    Text(vm.current_trip?.getEndLocation().address ?? "")
                        .frame(alignment: .trailing)
                }
                HStack{
                    Text("Total Time").frame(alignment: .leading)
                    Spacer()
                    Text("\(vm.total_time)")
                }
                HStack{
                    Text("Total Distance").frame(alignment: .leading)
                    Spacer()
                    Text("\(vm.total_distance)")
                }
            }
            .frame(minWidth: UIScreen.main.bounds.width - 20)
            .padding()
            
            VStack {
                TextField("Start Date", text: $startDate)
                TextField("End Date", text: $endDate)
            }
            .padding()
            
            Spacer(minLength: 200)
            
            Text("Stops")
                .font(.headline)
            
            NavigationLink("Add a Stop", destination: { FindStopView(vm: vm)} )
                
            ForEach(vm.current_trip?.getStops() ?? [], id: \.address) { stop in
                Text("\(stop.name)")
            }
            
            Spacer()
        }
    }
}

#Preview {
    TripView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "123 5th Street", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"))])), trip: .init(start_location: Restaurant(address: "123 street", name: "Tiffs", rating: 3.2), end_location: Hotel(address: "387 West Peachtree", name: "Hilton")))
}
