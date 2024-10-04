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
    
    /*-------------------------------------------------------------------------------------------------*/
    
    
    /*
     ------------------------------------------------------------------------------------------------
     Trips firebase
     -----------------------------------------------------------------------------------------------
     */
    
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
                    
                    // start location
                    let start_location_name = tripData["start_location_name"] as? String ?? ""
                    let start_location_address = tripData["start_location_address"] as? String ?? ""
                    let start_location_type = tripData["start_location_type"] as? String ?? ""
                    let start_POI = getPOI(name: start_location_name, address: start_location_address, type: start_location_type, needLatAndLong: false, longitude: nil, latitude: nil)
                    
                    // end location
                    let end_location_name = tripData["end_location_name"] as? String ?? ""
                    let end_location_address = tripData["end_location_address"] as? String ?? ""
                    let end_location_type = tripData["end_location_type"] as? String ?? ""
                    let end_POI = getPOI(name: end_location_name, address: end_location_address, type: end_location_type, needLatAndLong: false, longitude: nil, latitude: nil)
                    
                    let start_date = tripData["start_date"] as? String ?? ""
                    let start_time = tripData["start_time"] as? String ?? ""
                    let end_date = tripData["end_date"] as? String ?? ""
                    
                    let created_date = tripData["created_date"] as? String ?? ""
                    let modified_date = tripData["modified_date"] as? String ?? ""

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
                            let poi = getPOI(
                                name: poi_name,
                                             address: poi_address,
                                             type: poi_type, needLatAndLong:
                                    (poi_latitude != 0.0 && poi_longitude != 0.0),
                                             longitude: poi_longitude,
                                             latitude: poi_latitude
                            )
                            stops.append(poi)
                        } catch {
                            print("Error fetching stop \(stop): \(error)")
                        }
                    }
                    
                    let newTrip = Trip(
                        id: tripID,
                        start_location: start_POI,
                        end_location: end_POI,
                        start_date: start_date,
                        end_date: end_date,
                        stops: stops,
                        start_time: start_time,
                        created_date: created_date,
                        modified_date: modified_date
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

                                                
    private func getPOI(name: String, address: String, type: String, needLatAndLong: Bool, longitude: Double?, latitude: Double?) -> any POI {
        switch type {
        case "Restaurant":
            if needLatAndLong {
                return Restaurant(address: address, name: name, latitude: latitude, longitude: longitude)
            } else {
                return Restaurant(address: address, name: name)
            }
            
        case "RestStop":
            if needLatAndLong {
                return RestStop(address: address, name: name, latitude: latitude, longitude: longitude)
            } else {
                return RestStop(address: address, name: name)
            }
            
        case "GasStation":
            if needLatAndLong {
                return GasStation(name: name, address: address, longitude: longitude, latitude: latitude)
            } else {
                return GasStation(name: name, address: address)
            }
            
        case "GeneralLocation":
            if needLatAndLong {
                return GeneralLocation(address: address, name: name, latitude: latitude, longitude: longitude)
            } else {
                return GeneralLocation(address: address, name: name)
            }
            
        default:
            if needLatAndLong {
                return GeneralLocation(address: address, name: name, latitude: latitude, longitude: longitude)
            } else {
                return GeneralLocation(address: address, name: name)
            }
            
        }
    }

    /*-------------------------------------------------------------------------------------------------*/

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
