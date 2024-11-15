//
//  BeginningNavigationView.swift
//  Nomad
//
//  Created by Nicholas Candello on 11/14/24.
//
import SwiftUI

struct BeginningNavigationView: View {
    @ObservedObject var vm: UserViewModel
    @ObservedObject var navManager: NavigationManager
    @ObservedObject var mapManager: MapManager
    
    var startNavigation: () -> Void
    var cancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Route Preview")
                    .font(.title2)
                    .bold()
                Spacer()
                Button {
                    cancel()
                } label: {
                    Text("Cancel")
                        .foregroundStyle(.red)
                }

            }
            if let trip = vm.navigatingTrip {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            RouteListCircleView(aboveLine: false, belowLine: true)
                            POIArrivedView(poi: trip.getStartLocation())
                                .frame(height: 100)
                                .background(Color.white)
                                .foregroundStyle(Color.nomadDarkBlue)
                                .cornerRadius(20)
                                .padding(.vertical, 7)
                        }
                        ForEach(trip.getStops(), id: \.id) { poi in
                            HStack {
                                RouteListCircleView(aboveLine: true, belowLine: true)
                                
                                POIArrivedView(poi: poi)
                                    .frame(height: 100)
                                    .background(Color.white)
                                    .foregroundStyle(Color.nomadDarkBlue)
                                    .cornerRadius(20)
                                    .padding(.vertical, 7)
                            }
                            
                        }
                        HStack {
                            RouteListCircleView(aboveLine: true, belowLine: false)
                            POIArrivedView(poi: trip.getEndLocation())
                                .frame(height: 100)
                                .background(Color.white)
                                .foregroundStyle(Color.nomadDarkBlue)
                                .cornerRadius(20)
                                .padding(.vertical, 7)
                        }
                        
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 3)
                }
                HStack {
                    Spacer()
                    Button {
                        startNavigation()
                    } label: {
                        Text("Start Navigation")
                            .padding(.horizontal, 50)
                            .padding(.vertical, 15)
                            .background(Color.nomadDarkBlue)
                            .foregroundStyle(.white)
                            .cornerRadius(10)
                            .padding(.vertical, 12)
                            .padding(.bottom, 10)
                    }
                    Spacer()
                }
            }
            }
            .padding()
            .background(Color.nomadLightBlue)
            .cornerRadius(20)
            .offset(y: 20)
    }
}

struct RouteListCircleView: View {
    var aboveLine: Bool
    var belowLine: Bool
    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(maxWidth: 2, maxHeight: .infinity)
                .foregroundStyle(aboveLine ? Color.nomadDarkBlue : .clear)
            Circle()
                .stroke(Color.nomadDarkBlue, lineWidth: 2)
                .fill(.clear)
                .frame(width: 10, height: 10)
            Rectangle()
                .frame(maxWidth: 2, maxHeight: .infinity)
                .foregroundStyle(belowLine ? Color.nomadDarkBlue : .clear)
        }
    }
}
