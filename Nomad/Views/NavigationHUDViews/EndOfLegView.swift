//
//  EndOfLegView.swift
//  Nomad
//
//  Created by Nicholas Candello on 11/14/24.
//
import SwiftUI

struct EndOfLegView: View {
    @ObservedObject var navManager: NavigationManager
    var continueNavigation: () -> Void
    
    var reached_stop: any POI
    var next_stop: (any POI)?
    
    init(navManager: NavigationManager, continueNavigation: @escaping () -> Void) {
        self.navManager = navManager
        
        let (start, stop) = navManager.getCurrentAndNextPOI()
        self.reached_stop = start
        self.next_stop = stop
        print(reached_stop.name)
        print(next_stop?.name)
        
        self.continueNavigation = continueNavigation
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading) {
                Text("Welcome to:")
                    .font(.title2)
                    .bold()
                POIArrivedView(poi: reached_stop)
                    .frame(height: 100)
                    .background(Color.white)
                    .foregroundStyle(Color.nomadDarkBlue)
                    .cornerRadius(20)
                
            }.frame(maxWidth: .infinity, alignment: .leading)
            if let next = next_stop {
                Divider()
                    .foregroundStyle(Color.nomadDarkBlue)
                VStack(alignment: .leading) {
                    Text("Next:")
                        .font(.title2)
                        .bold()
                    POIArrivedView(poi: next)
                        .frame(height: 100)
                        .foregroundStyle(Color.nomadDarkBlue)
                        .background(Color.white)
                        .cornerRadius(20)
                    
                    
                }.frame(maxWidth: .infinity, alignment: .leading)
            } else {
                // route navigation is done
            }
            Button {
                continueNavigation()
            } label: {
                Text(continueButtonLabel())
                    .padding(.horizontal, 50)
                    .padding(.vertical, 15)
                    .background(Color.nomadDarkBlue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding(.vertical, 12)
            }
            
        }
        .padding()
        .background(Color.nomadLightBlue)
        .cornerRadius(20)
    }
    func continueButtonLabel() -> String {
        if next_stop != nil {
            return "Continue"
        } else {
            return "Finish"
        }
    }
}


struct POIArrivedView: View {
    
    var poi: any POI
    
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            
            AsyncImage(url: URL(string: poi.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60)
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
            } placeholder: {
                ProgressView()
                    .frame(width: 60, height: 60)
                    .cornerRadius(10)
                    .padding(.horizontal, 10)
            }
            
            
            
            // POI Information
            VStack(alignment: .leading, spacing: 5) {
                Text(poi.name)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(poi.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(3) // Allow unlimited lines
                    .multilineTextAlignment(.leading)
                
            }
            Spacer()
        }.padding()
    }
}

#Preview {
    let arrived_stop = UserViewModel.my_trips.first!.getStops().first!
    let next_stop = UserViewModel.my_trips.first!.getEndLocation()
    VStack {
        Spacer()
        EndOfLegView(navManager: NavigationManager(), continueNavigation: {})
            .frame(width: 400)
    }.edgesIgnoringSafeArea(.all)
}
