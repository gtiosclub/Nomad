//
//  EnhancedRoutePlanListView.swift
//  Nomad
//
//  Created by Austin Huguenard on 10/6/24.
//

import SwiftUI

struct EnhancedRoutePlanListView: View {
    @ObservedObject var vm: UserViewModel
    @State private var isEditing = false
    @State private var draggingIndex: Int? = nil
    @State private var newIndex: Int? = nil
    @State private var dragOffset = CGSize.zero
    @State private var stops: [any POI] = []
    @State var isEditable: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let startLocation = vm.current_trip?.getStartLocation() {
                createLocationView(location: startLocation, time: nil, isLast: false, isFirst: true, index: -1)
            }
            
            //if let stops = vm.current_trip?.getStops() {
            ForEach(stops.indices, id: \.self) { index in
                let stop = stops[index]
                let time = vm.times[safe: index]
                createLocationView(location: stop, time: time, isLast: false, isFirst: false, index: index)
                    .offset(draggingIndex == index ? dragOffset : .zero)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if isEditing {
                                    if draggingIndex == nil {
                                        draggingIndex = index
                                    }
                                    dragOffset = CGSize(width: 0, height: value.translation.height)
                                    let direction = dragOffset.height > 0 ? 1 : -1
                                    let tempIndex = min(max(0, index + direction * Int(abs(dragOffset.height / 95).rounded())), stops.count - 1)
                                    if tempIndex != index {
                                        newIndex = tempIndex
                                    }
                                }
                            }
                            .onEnded { _ in
                                if isEditing {
                                    if let draggedIndex = draggingIndex, let targetIndex = newIndex, draggedIndex != targetIndex {
                                        Task {
                                            await moveStop(from: draggedIndex, to: targetIndex)
                                        }
                                    }
                                    draggingIndex = nil
                                    newIndex = nil
                                    dragOffset = .zero
                                    stops = vm.current_trip?.getStops() ?? []
                                    
                                    if stops.isEmpty {
                                        isEditing = false
                                    }
                                }
                            })
            }
            
            if let endLocation = vm.current_trip?.getEndLocation() {
                createLocationView(location: endLocation, time: vm.times.last, isLast: true, isFirst: false, index: -1)
            }
        }
        .padding(.leading, 15)
        .padding(.top, isEditing ? -67 : -30)
        .padding(.vertical, 30)
        .frame(maxWidth: UIScreen.main.bounds.width - 40)
        .background(Color.nomadLightBlue)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onAppear {
            stops = vm.current_trip?.getStops() ?? []
            vm.populateLegInfo()
        }
        .onChange(of: vm.current_trip?.modified_date) {
            print("updating stops")
            stops = vm.current_trip?.getStops() ?? []
            if stops.isEmpty {
                isEditing = false
            }
        }
    }
      
    func formatTimeDuration(duration: TimeInterval?) -> String {
        let new_duration = TimeInterval(duration ?? 60.0)
        let minsLeft = Int(new_duration.truncatingRemainder(dividingBy: 60))
        let hours = Int(new_duration / 60)
        if hours > 0 {
            return "\(Int(new_duration / 60)) HR \(Int(minsLeft)) MIN"
        } else {
            return "\(Int(minsLeft)) MIN"
        }
    }
    
    private func createLocationView(location: any POI, time: Double?, isLast: Bool, isFirst: Bool, index: Int) -> some View {
        HStack(alignment: .center, spacing: 10) {
            let stops = vm.current_trip?.getStops() ?? []
            if !isEditing {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack {
                        if !isLast {
                            Rectangle()
                                .fill(Color(red: 0.18, green: 0.55, blue: 0.54))
                                .frame(width: 1.5, height: 90)
                                .offset(y: 68)
                        }
                        RouteCircle().padding(.top, 0)
                            .offset(y: 18)
                    }
                }
            } else {
                if (!isLast && !isFirst) {
                    Button(action: {
                        if vm.current_trip != nil {
                            Task {
                                vm.removeStop(stopId: stops[index].id)
                                await vm.updateRoute()
                                vm.populateLegInfo()
                            }
//                            vm.objectWillChange.send()
                        }
                        if stops.isEmpty {
                            isEditing = false
                        }
                    }) {
                        VStack(alignment: .leading) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 14)
                                    .fill(Color.nomadLightBlue)
                                    .frame(width: 36, height: 36)
                                Circle()
                                    .stroke(Color.red, lineWidth: 3)
                                    .frame(width: 16, height: 16)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(Color.red, lineWidth: 1.5)
                                            .frame(width: 7, height: 1.2)
                                    )
                            }
                            .offset(x: -3, y: 18)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else {
                    VStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.clear)
                            .frame(width: 36, height: 36)
                        Circle()
                            .stroke(Color.clear, lineWidth: 3)
                            .frame(width: 16, height: 16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.clear, lineWidth: 1.5)
                                    .frame(width: 7, height: 1.2)
                            )
                            .offset(y: isFirst ? 32 : 18)
                    }
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                // Drive Time
                if !isEditing, let time = time {
                    HStack {
                        Image(systemName: "car.side")
                            .font(.system(size: 12))
                        
                        Text(formatTimeDuration(duration: time))
                            .font(.caption)
                            .foregroundColor(.black)
                            .padding(.top, 10)
                            .padding(.bottom, 10)
                            .bold()
                            .frame(height: isEditing ? 40 : nil)
                    }
                }
                if isEditing {
                    Color.clear
                        .frame(height: 35)
                }
                
                // Stop Info
                HStack(alignment: .center, spacing: 10) {
                    // Placeholder for location image
                    if let imagable = location as? Imagable, let imageurl = imagable.getImageUrl() {
                        AsyncImage(url: URL(string: imageurl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 60)
                                .cornerRadius(10)
                        } placeholder: {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 80, height: 60)
                                .cornerRadius(10)
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80, height: 60)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 0.5)
                            )
                    }
                    
                    // Location details
                    VStack(alignment: .leading, spacing: 0) {
                        Text(location.getName())
                            .font(.headline)
                            .foregroundColor(.black)
                            .lineLimit(1)
                        
                        if let cuisine = (location as? Restaurant)?.getCuisine() {
                            Text("\(cuisine) Cuisine")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        HStack(spacing: 2) {
                            if let city = location.getCity(), !city.isEmpty {
                                Text("\(city) ")
                            } else if let city = vm.current_trip?.getStartCity(), isFirst {
                                Text(city)
                            } else if let city = vm.current_trip?.getEndCity(), isLast {
                                Text(city)
                            }
                            
                            if let ratable = location as? Ratable {
                                showRating(location: location, ratable: ratable)
                            }
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    }
                    if isEditing && !isFirst && !isLast {
                        Spacer()
                        HStack {
                            Image(systemName: "line.horizontal.3")
                                .font(.system(size: 22))
                                .foregroundColor(.gray)
                                .padding(.top, -4)
                        }
                        .padding(.top, 10)
                    }

                    if isFirst, !stops.isEmpty, isEditable {
                        Spacer()
                        Button(action: {
                            isEditing.toggle()
                        }) {
                            Text(isEditing ? "Done" : "Edit")
                                .font(.system(size: 16))
                                .frame(maxWidth: 60)
                                .frame(maxHeight: 30)
                                .background(Color.nomadDarkBlue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
//                                .shadow(color: .black.opacity(0.5), radius: 5, y: 3)
                        }
                        .offset(x: 3, y: -31)
                        .padding(0)
                    }
                }
                .padding(.top, isFirst ? 30 : 0)
            }
            Spacer()
        }
    }
        
    private func showRating(location: any POI, ratable: Ratable) -> some View {
        HStack(spacing: 0) {
            if (location.getCity()) != nil {
                Text("•")
            }
            Text(" \(String(format: "%.2f", ratable.getRating()))")
            Image(systemName: "star")
                .resizable()
                .frame(width: 14, height: 14)
                .foregroundColor(.secondary)
                .padding(.leading, 2)
        }
    }

    private func moveStop(from sourceIndex: Int, to destinationIndex: Int) async {
        guard sourceIndex != destinationIndex else { return }
        let adjustedDestinationIndex: Int
        if destinationIndex > sourceIndex {
            adjustedDestinationIndex = destinationIndex + 1
        } else {
            adjustedDestinationIndex = destinationIndex
        }
        let indexSet = IndexSet([sourceIndex])

        vm.reorderStops(fromOffsets: indexSet, toOffset: adjustedDestinationIndex)
        await vm.updateRoute()
        vm.populateLegInfo()
    }
}


#Preview {
    let trip = Trip(
        start_location: GeneralLocation(address: "177 North Avenue NW, Atlanta, GA 30332", name: "Georgia Tech", latitude: 0.0, longitude: 0.0),
        end_location: Hotel(address: "387 West Peachtree", name: "Hilton", latitude: 0.0, longitude: 0.0),
        stops: [Restaurant(address: "85 5th St. NW Atlanta, GA 30308", name: "Moes", rating: 4.0, cuisine: "Mexican", latitude: 0.0, longitude: 0.0), GeneralLocation(address: "630 10th St NW, Atlanta, GA 30318", name: "QuikTrip", latitude: 0.0, longitude: 0.0)]
    )

    let user = User(id: "89379", name: "Austin", trips: [trip])
    var vm = UserViewModel(user: user)
    vm.current_trip = trip

    return EnhancedRoutePlanListView(vm: vm)
}
