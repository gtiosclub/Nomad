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
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var startTime: Date = Date()
    
    @State private static var dateformatter = DateFormatter()
 
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
            }
            .frame(minWidth: UIScreen.main.bounds.width - 20)
            .padding()
            
            
            VStack {
                DatePicker(
                    "Start Date",
                    selection: $startDate,
                    displayedComponents: [.date]
                )

                DatePicker(
                    "End Date",
                    selection: $endDate,
                    displayedComponents: [.date]
                )


                HStack {
                    Spacer()
                    Button("Save Dates & Time") {
                        vm.updateStartDate(newStartDate: TripView.dateToString(date: startDate) ?? "")
                        vm.updateEndDate(newEndDate: TripView.dateToString(date: endDate) ?? "")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                }
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
    
    static func dateToString(date: Date) -> String? {
        dateformatter.dateFormat = "MM-dd-yyyy HH:mm:ss"
        return dateformatter.string(from: date)
    }

}

#Preview {
    TripView(vm: .init(user: User(id: "89379", name: "austin", trips: [Trip(start_location: GeneralLocation(address: "123 5th Street", name: "Georgia Tech"), end_location: Hotel(address: "387 West Peachtree", name: "Hilton"))])), trip: .init(start_location: Restaurant(address: "123 street", name: "Tiffs", rating: 3.2), end_location: Hotel(address: "387 West Peachtree", name: "Hilton")))
}

