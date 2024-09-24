//
//  UserViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//

import Foundation
import MapKit

class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var current_trip: Trip?
    var start_date: String?
    var end_date: String?
    
    func setStartDate(startDate: String) {
            if var user = self.user, var trip = self.current_trip {
                trip.start_date = startDate
                
                if let tripIndex = user.trips.firstIndex(where: { $0.id == trip.id }) {
                    user.trips[tripIndex] = trip
                    self.user = user
                }
            }
        }

        func setEndDate(endDate: String) {
            if var user = self.user, var trip = self.current_trip {
                trip.end_date = endDate
                
                if let tripIndex = user.trips.firstIndex(where: { $0.id == trip.id }) {
                    user.trips[tripIndex] = trip
                    self.user = user
                }
            }
        }
    }
