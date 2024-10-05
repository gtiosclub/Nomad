//
//  LocationSearchBox.swift
//  Nomad
//
//  Created by Jaehun Baek on 9/19/24.
//

import SwiftUI
import Combine
import CoreLocation
import MapKit

struct LocationSearchBox: View {
    @StateObject private var mapSearch = MapSearch()
    // Form Variables
    
    @FocusState private var isFocused: Bool
    
    @State private var btnHover = false
    @State private var isBtnActive = false
    
    @Binding var selectedAddress: String
    
    
    // Main UI
    
    var body: some View {
        
        VStack {
            TextField("Enter Location Here", text: $mapSearch.searchTerm)
                .focused($isFocused)
                .padding()
                .background(.white)
                .cornerRadius(10)
                .padding(.horizontal, 10)
            
            // Show auto-complete results
            if !mapSearch.searchTerm.isEmpty && mapSearch.searchTerm != self.selectedAddress {
                List {
                    ForEach(mapSearch.locationResults, id: \.self) { location in
                        Button {
                            reverseGeo(location: location)
                        } label: {
                            VStack(alignment: .leading) {
                                Text(location.title)
                                    .foregroundColor(Color.black)
                                Text(location.subtitle)
                                    .font(.system(.caption))
                                    .foregroundColor(Color.black)
                            }
                        }
                    }
                }
                
            }
            
        }
    }
    func reverseGeo(location: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: location)
        let search = MKLocalSearch(request: searchRequest)
        var coordinateK : CLLocationCoordinate2D?
        search.start { (response, error) in
            if error == nil, let coordinate = response?.mapItems.first?.placemark.coordinate {
                coordinateK = coordinate
            }
            
            if let c = coordinateK {
                let location = CLLocation(latitude: c.latitude, longitude: c.longitude)
                CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                    
                    guard let placemark = placemarks?.first else {
                        let errorString = error?.localizedDescription ?? "Unexpected Error"
                        print("Unable to reverse geocode the given location. Error: \(errorString)")
                        return
                    }
                    
                    let reversedGeoLocation = ReversedGeoLocation(with: placemark)
                    
                    mapSearch.searchTerm = "\(reversedGeoLocation.streetNumber) \(reversedGeoLocation.streetName) \(reversedGeoLocation.city) \(reversedGeoLocation.state) \(reversedGeoLocation.zipCode)"
                    selectedAddress = mapSearch.searchTerm
                    isFocused = false
                    
                }
            }
        }
    }
} // End Struct

struct Test_Previews: PreviewProvider {
    static var previews: some View {
        LocationSearchBox(selectedAddress: Binding.constant(""))
    }
}

#Preview {
    LocationSearchBox(selectedAddress: Binding.constant(""))
}
