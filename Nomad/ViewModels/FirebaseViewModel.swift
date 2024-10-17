//
//  FirebaseViewModel.swift
//  Nomad
//
//  Created by Nicholas Candello on 9/15/24.
//
import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import SwiftUI

class FirebaseViewModel: ObservableObject {
    let auth = Auth.auth()
    let db = Firestore.firestore()
    @Published var errorText: String? = nil
    @Published var isLoading: Bool = false

    func firebase_email_password_sign_up(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        auth.createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorText = self.parseFirebaseError(error)
                completion(false)
                return
            }
            
            guard let user = authResult?.user else {
                self.errorText = "Failed to create user. Please try again."
                completion(false)
                return
            }
            
            db.collection("USERS").document(user.uid).setData([
                "email": email
            ]) { error in
                if let error = error {
                    self.errorText = "Failed to save user data: \(error.localizedDescription)"
                    completion(false)
                } else {
                    self.errorText = nil
                    completion(true)
                }
            }
        }
    }
    
    func firebase_email_password_sign_in(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        auth.signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            self.isLoading = false
            
            if let error = error {
                self.errorText = self.parseFirebaseError(error)
                completion(false)
                return
            }
            
            if authResult?.user != nil {
                db.collection("USERS").document((authResult?.user.uid)!).getDocument { (document, error) in
                    if let document = document, document.exists {
                        if let age = document.data()?["age"] as? Int {
                            print("User's age: \(age)")
                            self.errorText = nil
                            completion(true)
                        } else {
                            print("Age field not found or not an integer")
                            self.errorText = "Failed to retrieve user data"
                            completion(false)
                        }
                    } else {
                        print("Document does not exist")
                        self.errorText = "User document not found"
                        completion(false)
                    }
                }
            } else {
                self.errorText = "Failed to log in. Please try again."
                completion(false)
            }
            
        }
    }
    
    /*-------------------------------------------------------------------------------------------------*/
    
    func addTripToUser(userID: String, tripID: String) async -> Bool {
        let docRef = db.collection("USERS").document(userID)
        do {
            let document = try await docRef.getDocument()
            guard var trips = document.data()?["trips"] as? [String] else {
                print("Document does not exist or 'completedCountries' is not an array.")
                return false
            }
            if (!trips.contains(tripID)) {
                trips.append(tripID)
                try await db.collection("USERS").document(userID).updateData(["trips": trips])
                return true
                    
            } else {
                print("Trip already in user trip list")
                return false;
            }
        } catch {
            print(error)
            return false
        }
    }
    
    func createTrip(tripID: String, startLocationName: String, startLocationAddress: String, endLocationName: String, endLocationAddress: String, createdDate: String, modifiedDate: String) async -> Bool {
        let tripDocRef = db.collection("TRIPS").document(tripID)

        let tripData: [String: Any] = [
            "created_date": createdDate,
            "modified_date": modifiedDate,
            "start_id": "start",
            "end_id": "end"
        ]
        do {
            try await tripDocRef.setData(tripData)

            let stopsCollection = tripDocRef.collection("STOPS")

            let startData: [String: Any] = [
                "name": startLocationName,
                "address": startLocationAddress,
                "type": "GeneralLocation"
            ]
            try await stopsCollection.document("start").setData(startData)

            let endData: [String: Any] = [
                "name": endLocationName,
                "address": endLocationAddress,
                "type": "GeneralLocation"
            ]
            try await stopsCollection.document("end").setData(endData)
            return true
        } catch {
            print("Error creating trip or stops: \(error)")
            return false
        }
    }


    func modifyStartDate(userID: String, tripID: String, newStartDate: String, modifiedDate: String) async -> Bool {
        do {
            try await db.collection("TRIPS").document(tripID).updateData(["start_date" : newStartDate, "modified_date" : modifiedDate])
            return true
        } catch {
            print(error)
            return false
        }
    }

    func modifyEndDate(userID: String, tripID: String, newEndDate: String, modifiedDate: String) async -> Bool {
        do {
            try await db.collection("TRIPS").document(tripID).updateData(["end_date" : newEndDate, "modified_date" : modifiedDate])
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func modifyStartLocationAndDate(tripID: String, startLocName: String, startLocAddress: String, modifiedDate: String) async -> Bool {
        do {
            try await db.collection("TRIPS").document(tripID).updateData(["start_location_address" : startLocAddress, "start_location_name" : startLocName, "modified_date" : modifiedDate])
            return true
        } catch {
            print(error)
            return false
        }
    }

    func modifyEndLocationAndDate(tripID: String, endLocName: String, endLocAddress: String, modifiedDate: String) async -> Bool {
        do {
            try await db.collection("TRIPS").document(tripID).updateData(["end_location_address" : endLocAddress, "end_location_name" : endLocName, "modified_date" : modifiedDate])
            return true
        } catch {
            print(error)
            return false
        }
    }

    func getAllTrips(userID: String) async -> [Trip] {
        var trips: [Trip] = []
        let user = db.collection("USERS").document(userID)

        do {
            let trip_document = try await user.getDocument()
            guard let tripDocs = trip_document.data()?["trips"] as? [String] else {
                print("Unable to retrieve trips array from user document")
                return []
            }

            for tripID in tripDocs {
                let tripRef = db.collection("TRIPS").document(tripID)

                do {
                    let tripDoc = try await tripRef.getDocument()
                    guard let tripData = tripDoc.data() else {
                        print("Trip document \(tripID) does not exist or is empty")
                        continue
                    }

                    let start_location_id = tripData["start_id"] as? String ?? ""
                    let end_location_id = tripData["end_id"] as? String ?? ""

                    // Initialize start_location and end_location variables as optional
                    var start_location: (any POI)?
                    var end_location: (any POI)?

                    // Fetch start and end location data
                    let startRef = tripDoc.reference.collection("STOPS").document(start_location_id)
                    let endRef = tripDoc.reference.collection("STOPS").document(end_location_id)
                    do {
                        let startDoc = try await startRef.getDocument()
                        let endDoc = try await endRef.getDocument()

                        guard let startData = startDoc.data() else {
                            print("Cannot find start point for trip \(tripID)")
                            continue // Exit current iteration of loop if data is missing
                        }
                        guard let endData = endDoc.data() else {
                            print("Cannot find end point for trip \(tripID)")
                            continue
                        }

                        let start_name = startData["name"] as? String ?? ""
                        let start_address = startData["address"] as? String ?? ""
                        let start_type = startData["type"] as? String ?? ""
                        let start_lat = startData["latitude"] as? Double ?? 0.0
                        let start_long = startData["longitude"] as? Double ?? 0.0
                        let start_city = startData["city"] as? String ?? ""

                        start_location = getPOI(
                            name: start_name,
                            address: start_address,
                            type: start_type,
                            longitude: start_long,
                            latitude: start_lat,
                            city: start_city
                        )

                        let end_name = endData["name"] as? String ?? ""
                        let end_address = endData["address"] as? String ?? ""
                        let end_type = endData["type"] as? String ?? ""
                        let end_lat = endData["latitude"] as? Double ?? 0.0
                        let end_long = endData["longitude"] as? Double ?? 0.0
                        let end_city = endData["city"] as? String ?? ""

                        end_location = getPOI(
                            name: end_name,
                            address: end_address,
                            type: end_type,
                            longitude: end_long,
                            latitude: end_lat,
                            city: end_city
                        )

                    } catch {
                        print("Error fetching start or end location: \(error)")
                        continue
                    }

                    guard let validStartLocation = start_location, let validEndLocation = end_location else {
                        print("Start or end location is missing for trip \(tripID)")
                        continue
                    }

                    let start_date = tripData["start_date"] as? String ?? ""
                    let start_time = tripData["start_time"] as? String ?? ""
                    let end_date = tripData["end_date"] as? String ?? ""
                    let created_date = tripData["created_date"] as? String ?? ""
                    let modified_date = tripData["modified_date"] as? String ?? ""
                    let name = tripData["name"] as? String ?? ""
                    let isPrivate = tripData["isPrivate"] as? Bool ?? true

                    let stops_data = tripData["stops"] as? [String] ?? []
                    var stops: [any POI] = []

                    for stop in stops_data {
                        let stopRef = tripDoc.reference.collection("STOPS").document(stop)
                        do {
                            let stopDoc = try await stopRef.getDocument()
                            guard let stopData = stopDoc.data() else {
                                print("Cannot find stop \(stop)")
                                continue
                            }

                            let poi_name = stopData["name"] as? String ?? ""
                            let poi_address = stopData["address"] as? String ?? ""
                            let poi_type = stopData["type"] as? String ?? ""
                            let poi_latitude = stopData["latitude"] as? Double ?? 0.0
                            let poi_longitude = stopData["longitude"] as? Double ?? 0.0
                            let poi_city = stopData["city"] as? String ?? ""
                            let poi_closetime: String? = stopData["close_time"] as? String
                            let poi_opentime: String? = stopData["open_time"] as? String
                            let poi_price: Int? = stopData["price"] as? Int
                            let poi_rating: Double? = stopData["rating"] as? Double
                            let poi_website: String? = stopData["website"] as? String
                            let poi_cuisine: String? = stopData["cuisine"] as? String

                            let poi = getPOI(
                                name: poi_name,
                                address: poi_address,
                                type: poi_type,
                                longitude: poi_longitude,
                                latitude: poi_latitude,
                                city: poi_city,
                                cuisine: poi_cuisine,
                                open_time: poi_opentime,
                                close_time: poi_closetime,
                                rating: poi_rating,
                                price: poi_price,
                                website: poi_website
                            )
                            stops.append(poi)
                        } catch {
                            print("Error fetching stop \(stop): \(error)")
                        }
                    }

                    let newTrip = Trip(
                        id: tripID,
                        start_location: validStartLocation,
                        end_location: validEndLocation,
                        start_date: start_date,
                        end_date: end_date,
                        created_date: created_date,
                        modified_date: modified_date,
                        stops: stops,
                        start_time: start_time,
                        name: name,
                        isPrivate: isPrivate
                    )
                    trips.append(newTrip)

                } catch {
                    print("Error fetching trip \(tripID): \(error)")
                }
            }
        } catch {
            print("Error fetching user document: \(error)")
            return []
        }
        return trips
    }
    
    private func getPOI(name: String, address: String, type: String, longitude: Double, latitude: Double, city: String?, cuisine: String? = nil, open_time: String? = nil, close_time: String? = nil, rating: Double? = nil, price: Int? = nil, website: String? = nil) -> any POI {
            switch type {
            case "Restaurant":
                return Restaurant(address: address, name: name, rating: rating, cuisine: cuisine, price: price, website: website, latitude: latitude, longitude: longitude, city: city)
            case "RestStop":
                return RestStop(address: address, name: name, latitude: latitude, longitude: longitude, city: city)
            case "GasStation":
                return GasStation(name: name, address: address, longitude: longitude, latitude: latitude, city: city)
            case "GeneralLocation":
                return GeneralLocation(address: address, name: name, latitude: latitude, longitude: longitude, city: city)
            case "Hotel":
                return Hotel(address: address, name: name, rating: rating, website: website, latitude: latitude, longitude: longitude, city: city)
            default:
                return GeneralLocation(address: address, name: name, latitude: latitude, longitude: longitude, city: city)
            }
        }
    
    /*-------------------------------------------------------------------------------------------------*/

    private func parseFirebaseError(_ error: Error) -> String {
        let errorCode = (error as NSError).code
        switch errorCode {
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email address."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "The email address is already in use."
        case AuthErrorCode.weakPassword.rawValue:
            return "The password is too weak. Please use a stronger password."
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Please try again."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email."
        default:
            return error.localizedDescription
        }
    }
    
    
    func getAPIKeys() async throws -> [String: String] {
        var apimap: [String: String] = [:]
        
        let getdocs = try await db.collection("API_KEYS").getDocuments()
        
        for doc in getdocs.documents {
            if let key = doc.data()["key"] as? String {
                apimap[doc.documentID] = key
            }
        }
        
        return apimap
    }

}



                 
