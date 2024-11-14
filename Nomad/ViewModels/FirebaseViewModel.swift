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
import MapKit
import SwiftUI

class FirebaseViewModel: ObservableObject {
    static var isListenerInitialized = false  // Static variable to prevent multiple listeners

    let auth = Auth.auth()
    let db = Firestore.firestore()
    @Published var current_user: User? = nil
    @Published var errorText: String? = nil
    @Published var isLoading: Bool = false
    @Published var isAuthenticated = false
    var onSetupCompleted: ((FirebaseViewModel) -> Void)?
    
    static let vm = FirebaseViewModel()

    private init(current_user: User? = nil, errorText: String? = nil) {
        self.current_user = current_user
        self.errorText = errorText
        print("inside fbVM init")

        if !FirebaseViewModel.isListenerInitialized {
            FirebaseViewModel.isListenerInitialized = true
            auth.addStateDidChangeListener { [weak self] auth, user in
                DispatchQueue.main.async {
                    self?.handleAuthChange(user)
                }
            }
        }
    }

    private func handleAuthChange(_ user: FirebaseAuth.User?) {
        self.isAuthenticated = user != nil

        if let user = user, let username = user.displayName {
            if self.current_user?.id != username {
                print("User Found")
                print("Setting User: \(username)")
                Task {
                    await self.setCurrentUser(userId: username)
                    UserDefaults.standard.setValue(true, forKey: "log_Status")
                }
            }
        } else {
            UserDefaults.standard.setValue(false, forKey: "log_Status")
        }
    }
    
    func configure() {
        self.onSetupCompleted?(self)
    }
    
    func firebase_email_password_sign_up(email: String, password: String, name: String, completion: @escaping (Bool) -> Void) {
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
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = name
            changeRequest.commitChanges { error in
                if let error = error {
                    self.errorText = "Failed to update user display name: \(error.localizedDescription)"
                    completion(false)
                }
            }
            let trips: [String] = []
            db.collection("USERS").document(name).setData([
                "email": email, "name": name, "trips": trips
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
                self.errorText = nil
                completion(true)
            } else {
                self.errorText = "Failed to log in. Please try again."
                completion(false)
            }
            
        }
    }
    
    func firebase_sign_out() {
        do {
            try auth.signOut()
            current_user = nil
        } catch let signOutError as NSError {
        
            print("Error signing out: %@", signOutError)
        }
    }
    
    func setCurrentUser(userId: String) async -> User? {
        print("attempting to set current user")
        if userId.isEmpty {
            return nil
        }
        
        // Only fetch if current_user is nil or different user
        if current_user == nil || current_user?.id != userId {
            do {
                // First get the user document
                let document = try await db.collection("USERS").document(userId).getDocument()
                
                guard let documentData = document.data() else {
                    print("User document does not contain any data.")
                    return nil
                }
                
                // Then fetch all trips
//                let allTrips: [String: [Trip]] = await getAllTrips(userID: userId)
                
                DispatchQueue.main.async {
                    self.current_user = User(
                        id: document.documentID,
                        name: documentData["name"] as? String ?? "",
                        email: documentData["email"] as? String ?? ""
//                        trips: allTrips["future"] ?? [],
//                        pastTrips: allTrips["past"] ?? [],
//                        currentTrip: allTrips["present"] ?? []
                    )
                }
                
                return self.current_user
            } catch {
                print("SetCurrentUserError: \(error.localizedDescription)")
                return nil
            }
        }
        return current_user
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
    
    // Converts NomadRoute coordinates (use jsonCoordinates) method and store in firebase
//    func storeRoute(route: NomadRoute) async -> Bool {
//        do {
//            try await tripDocRef.setData(tripData)
//
//            let stopsCollection = tripDocRef.collection("STOPS")
//
//            let startData: [String: Any] = [
//                "name": startLocationName,
//                "address": startLocationAddress,
//                "type": "GeneralLocation"
//            ]
//            try await stopsCollection.document("start").setData(startData)
//
//            let endData: [String: Any] = [
//                "name": endLocationName,
//                "address": endLocationAddress,
//                "type": "GeneralLocation"
//            ]
//            try await stopsCollection.document("end").setData(endData)
//            return true
//        } catch {
//            print("Error creating trip or stops: \(error)")
//            return false
//        }
//    }
//    func createTrip(tripID: String, startLocationName: String, startLocationAddress: String, endLocationName: String, endLocationAddress: String, createdDate: String, modifiedDate: String) async -> Bool {
//        let tripDocRef = db.collection("TRIPS").document(tripID)
//        let tripData: [String: Any] = [
//            "created_date": createdDate,
//            "modified_date": modifiedDate,
//            "start_id": "start",
//            "end_id": "end",
//            "stops": []
//        ]
//        do {
//            try await tripDocRef.setData(tripData)
//            let stopsCollection = tripDocRef.collection("STOPS")
//
//            let startData: [String: Any] = [
//                "name": startLocationName,
//                "address": startLocationAddress,
//                "type": "GeneralLocation"
//            ]
//            try await stopsCollection.document("start").setData(startData)
//
//            let endData: [String: Any] = [
//                "name": endLocationName,
//                "address": endLocationAddress,
//                "type": "GeneralLocation"
//            ]
//            try await stopsCollection.document("end").setData(endData)
//            return true
//        } catch {
//            print("Error creating trip or stops: \(error)")
//            return false
//        }
//    }
    func createTrip(tripID: String, createdDate: String, modifiedDate: String, startDate: String, startTime: String, endDate: String, isPrivate: Bool,  startLocation: any POI , endLocation: any POI, routeName: String, stops: [any POI]) async -> Bool {
        
        let tripDocRef = db.collection("TRIPS").document(tripID)
        let stopIDs = stops.map { $0.id }
        let tripData: [String: Any] = [
            "created_date": createdDate,
            "end_date" : endDate,
            "end_id" : "end",
            "isPrivate" : isPrivate,
            "modified_date": modifiedDate,
            "name" : routeName,
            "start_date" : startDate,
            "start_id" : "start",
            "start_time" : startTime,
            "images" : [],
            "stops": []
        ]
        do {
            try await tripDocRef.setData(tripData)
            
            let stopsCollection = tripDocRef.collection("STOPS")
            
            let startData: [String: Any] = [
                "name": startLocation.getName(),
                "address": startLocation.getAddress(),
                "city" : startLocation.getCity() ?? "",
                "latitude" : startLocation.getLatitude(),
                "longitude" : startLocation.getLongitude(),
                "type": "GeneralLocation"
            ]
            try await stopsCollection.document("start").setData(startData)
            
            let endData: [String: Any] = [
                "name": endLocation.getName(),
                "address": endLocation.getAddress(),
                "city" : endLocation.getCity() ?? "",
                "latitude" : endLocation.getLatitude(),
                "longitude" : endLocation.getLongitude(),
                "type": "GeneralLocation"
            ]
            try await stopsCollection.document("end").setData(endData)
            
            for (index, stop) in stops.enumerated() {
                let stopAdded = await addStopToTrip(tripID: tripID, stop: stop, index: index + 1)
                if !stopAdded {
                    print("Failed to add stop \(stop.name)")
                    return false
                }
            }
            return true
        } catch {
            print("Error creating trip or stops: \(error)")
            return false
        }
    }
    
    func createCopyTrip(newTripID: String, oldTripID: String, createdDate: String) async -> Bool {
        let db = Firestore.firestore()
        
        do {
            let document = try await db.collection("TRIPS").document(oldTripID).getDocument()
            let stopsDocs = try await db.collection("TRIPS").document(oldTripID).collection("STOPS").getDocuments()
            
            if document.exists {
                var data = document.data() ?? [:]
                data["created_date"] = createdDate
                data["modified_date"] = createdDate
                
                try await db.collection("TRIPS").document(newTripID).setData(data)
                let newTripDoc = db.collection("TRIPS").document(newTripID).collection("STOPS")
                for document in stopsDocs.documents {
                    let name = document.documentID
                    let data = document.data()
                    try await newTripDoc.document(name).setData(data)
                }
                return true
            } else {
                print("Old trip document does not exist")
                return false
            }
            
        } catch {
            print(error)
            return false
        }
    }
    
    // Fetch coordinates JSON from firebase and convert to coordinates
    func fetchRoutes() async throws -> [String: NomadRoute] {
        let getdocs = try await db.collection("ROUTES").getDocuments() // TODO: Change this
        
        // TODO: Integrate UserViewModel to use its mapmanager
        let mapManager = MapManager.manager
        return try await mapManager.docsToNomadRoute(docs: getdocs.documents)
    }
    
    func modifyHasDriven(tripID: String, hasDriven: Int) async -> Bool {
        do {
            try await db.collection("TRIPS").document(tripID).updateData(["hasDriven" : hasDriven])
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func addStopToTrip(tripID: String, stop: any POI, index: Int) async -> Bool {
        // Add stop to tripID array
        let docRef = db.collection("TRIPS").document(tripID)
        do {
            let document = try await docRef.getDocument()
            guard var stops = document.data()?["stops"] as? [String] else {
                print("Document does not exist or stops is not an array.")
                return false
            }
            if (!stops.contains(stop.name)) {
                if (index >= 0 || index > stops.count) {
                    stops.insert(stop.name, at: index)
                } else {
                    print("Invalid Index")
                    return false;
                }
                try await db.collection("TRIPS").document(tripID).updateData(["stops": stops])
            } else {
                print("Stop already in user stop list")
                return false;
            }
        } catch {
            print(error)
            return false
        }
        
        //add stop to collections

        var cuisine: String = ""
        var price: Int = -1
        var rating: Double = -1
        var website: String = ""
        if let restaurant = stop as? Restaurant {
            cuisine = restaurant.cuisine ?? ""
            price = restaurant.price ?? -1
            rating = restaurant.rating ?? -1.0
            website = restaurant.website ?? ""
        }
        if let hotel = stop as? Hotel {
            rating = hotel.rating ?? -1.0
            website = hotel.website ?? ""
        }
        do {
            try await db.collection("TRIPS").document(tripID).collection("STOPS").document(stop.name).setData(["name" : stop.name, "address" : stop.address, "type" : "\(type(of: stop))", "latitude" : stop.latitude, "longitude" : stop.longitude, "city" : stop.city ?? "", "cuisine" : cuisine, "price" : price, "rating" : rating, "website" : website, "imageURL": stop.imageUrl ?? ""])
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    func updateStop(tripID: String, stop: any POI, index: Int, document: DocumentSnapshot) async -> Bool {
        let stopDocRef = document.reference
        
        var updateData = [String: Any]()
        
        if document.data()?["name"] as? String != stop.getName() {
            updateData["name"] = stop.getName()
        }
        if document.data()?["address"] as? String != stop.getAddress() {
            updateData["address"] = stop.getAddress()
        }
        if document.data()?["city"] as? String != stop.getCity() {
            updateData["city"] = stop.getCity() ?? ""
        }
        if document.data()?["latitude"] as? Double != stop.getLatitude() {
            updateData["latitude"] = stop.getLatitude()
        }
        if document.data()?["longitude"] as? Double != stop.getLongitude() {
            updateData["longitude"] = stop.getLongitude()
        }
        if document.data()?["type"] as? String != "\(type(of: stop))" {
            updateData["type"] = "\(type(of: stop))"
        }
        
        if let restaurant = stop as? Restaurant {
            if document.data()?["cuisine"] as? String != restaurant.cuisine {
                updateData["cuisine"] = restaurant.cuisine ?? ""
            }
            if document.data()?["price"] as? Int != restaurant.price {
                updateData["price"] = restaurant.price ?? -1
            }
            if document.data()?["rating"] as? Double != restaurant.rating {
                updateData["rating"] = restaurant.rating ?? -1.0
            }
            if document.data()?["website"] as? String != restaurant.website {
                updateData["website"] = restaurant.website ?? ""
            }
        } else if let hotel = stop as? Hotel {
            if document.data()?["rating"] as? Double != hotel.rating {
                updateData["rating"] = hotel.rating ?? -1.0
            }
            if document.data()?["website"] as? String != hotel.website {
                updateData["website"] = hotel.website ?? ""
            }
        }

        if !updateData.isEmpty {
            do {
                try await stopDocRef.setData(updateData, merge: true)
                print("Updated stop \(stop.getName())")
                return true
            } catch {
                print("Error updating stop: \(error)")
                return false
            }
        }
        return true
    }


    
    func removeStopFromTrip(tripID: String, stop: any POI) async -> Bool {
        // Remove stop from tripID array
        let docRef = db.collection("TRIPS").document(tripID)
        do {
            let document = try await docRef.getDocument()
            guard var stops = document.data()?["stops"] as? [String] else {
                print("Document does not exist or stops is not an array.")
                return false
            }
            if (stops.contains(stop.name)) {
                if let index = stops.firstIndex(of: stop.name) {
                    stops.remove(at: index)
                } else {
                    return false;
                }
                try await db.collection("TRIPS").document(tripID).updateData(["stops": stops])
            } else {
                print("Stop not in user stop list")
                return false;
            }
        } catch {
            print(error)
            return false
        }
        do {
            try await db.collection("TRIPS").document(tripID).collection("STOPS").document(stop.name).delete()
            return true
        } catch {
            print(error)
            return false
        }
        //remove stop from collection
        
    }
    
    func updateStopArray(tripID: String, stops: [String]) async -> Bool {
        if Set(stops).count != stops.count {
            print("reordered stops list contains duplicates")
            return false
        }
        do {
            let querySnapshot = try await db.collection("TRIPS").document(tripID).collection("STOPS").getDocuments()
            var documentCount = 0
            for document in querySnapshot.documents {
                let documentName = document.documentID
                if documentName == "end" || documentName == "start" {
                    continue
                }
                print(documentName)
                if !stops.contains(documentName) {
                    print("Reordered list is missing stop")
                    return false
                }
                documentCount += 1
            }
            if documentCount != stops.count {
                print("Inputted stop list has extra stops")
                return false
            }
        } catch {
            print(error)
            return false
        }

        do {
            try await db.collection("TRIPS").document(tripID).updateData(["stops": stops])
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    
    func getAllPublicTrips(userID: String) async -> [Trip] {
            var public_trips : [Trip] = []
            var public_trip_names : [String] = []
            
            var user_trip_ids: [String] = []
            let userDocRef = db.collection("USERS").document(userID)
            do {
                let document = try await userDocRef.getDocument()
                user_trip_ids = document.data()?["trips"] as? [String] ?? []
            } catch {
                print(error)
            }
        
        
            let tripsDocRef = db.collection("TRIPS")
            do {
                let tripDocuments = try await tripsDocRef.getDocuments()
                for document in tripDocuments.documents {
//                    print("document is \(document.documentID)")
                    if (user_trip_ids.contains(document.documentID)) {continue}
                    
                    let tripData = document.data()
                    
                    let isPrivate = tripData["isPrivate"] as? Bool ?? true
                    if isPrivate {continue}

                    let start_location_id = tripData["start_id"] as? String ?? ""
                    let end_location_id = tripData["end_id"] as? String ?? ""
                    let hasDriven = tripData["hasDriven"] as? Int ?? 2
                    var start_location: (any POI)?
                    var end_location: (any POI)?
                    let startRef = document.reference.collection("STOPS").document(start_location_id)
                    let endRef = document.reference.collection("STOPS").document(end_location_id)
                    
                    do {
                        let startDoc = try await startRef.getDocument()
                        let endDoc = try await endRef.getDocument()

                        guard let startData = startDoc.data() else {
                            print("Cannot find start point for trip \(document.documentID)")
                            continue
                        }
                        guard let endData = endDoc.data() else {
                            print("Cannot find end point for trip \(document.documentID)")
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
                        print("Start or end location is missing for trip \(document.documentID)")
                        continue
                    }

                    let start_date = tripData["start_date"] as? String ?? ""
                    let start_time = tripData["start_time"] as? String ?? ""
                    let end_date = tripData["end_date"] as? String ?? ""
                    let created_date = tripData["created_date"] as? String ?? ""
                    let modified_date = tripData["modified_date"] as? String ?? ""
                    let name = tripData["name"] as? String ?? ""

                    let stops_data = tripData["stops"] as? [String] ?? []
                    var stops: [any POI] = []

                    for stop in stops_data {
                        let stopRef = document.reference.collection("STOPS").document(stop)
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
                            let poi_price: Int? = stopData["price"] as? Int
                            let poi_rating: Double? = stopData["rating"] as? Double
                            let poi_website: String? = stopData["website"] as? String
                            let poi_cuisine: String? = stopData["cuisine"] as? String
                            let poi_image: String? = stopData["imageURL"] as? String ?? ""

                            let poi = getPOI(
                                name: poi_name,
                                address: poi_address,
                                type: poi_type,
                                longitude: poi_longitude,
                                latitude: poi_latitude,
                                city: poi_city,
                                cuisine: poi_cuisine,
                                rating: poi_rating,
                                price: poi_price,
                                website: poi_website,
                                imageURL: poi_image
                            )
                            stops.append(poi)
                        } catch {
                            print("Error fetching stop \(stop): \(error)")
                        }
                    }

                    let newTrip = Trip(
                        id: document.documentID,
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
                    if (!newTrip.isPrivate) {
                        public_trips.append(newTrip)
                        public_trip_names.append(newTrip.getName())
                    }
                }
            } catch {
                print(error)
            }
            return public_trips
        }
    
    func modifyTrip(tripID: String, trip: Trip) async -> Bool {

        let tripDocRef = db.collection("TRIPS").document(tripID)
        let stopsCollectionRef = tripDocRef.collection("STOPS")

        let stopIDs = trip.getStops().map { $0.id }
        let tripData: [String: Any] = [
            "created_date": trip.getCreatedDate(),
            "end_date": trip.getEndDate(),
            "isPrivate": trip.isPrivate,
            "modified_date": trip.getModifyDate(),
            "name": trip.getName(),
            "start_date": trip.getStartDate(),
            "start_time": trip.getStartTime(),
            "images": trip.getImages(),
            "stops": []
        ]

        do {
            try await tripDocRef.setData(tripData, merge: true)

            let existingStopsSnapshot = try await stopsCollectionRef.getDocuments()
            var existingStopsMap = [String: DocumentSnapshot]()
            
            for document in existingStopsSnapshot.documents {
                existingStopsMap[document.documentID] = document
            }

            var processedStopIDs = Set<String>()

            for (index, stop) in trip.getStops().enumerated() {
                processedStopIDs.insert(stop.id)
                
                if let existingStopDoc = existingStopsMap[stop.id] {
                    let updated = await updateStop(tripID: tripID, stop: stop, index: index + 1, document: existingStopDoc)
                    if !updated {
                        print("Failed to update stop \(stop.getName())")
                        return false
                    }
                } else {
                    let added = await addStopToTrip(tripID: tripID, stop: stop, index: index + 1)
                    if !added {
                        print("Failed to add new stop \(stop.getName())")
                        return false
                    }
                }
            }

            for (stopID, document) in existingStopsMap {
                if !processedStopIDs.contains(stopID) {
                    try await document.reference.delete()
                    print("Deleted stop with ID \(stopID)")
                }
            }

            print("Trip modified successfully.")
            return true
        } catch {
            print("Error modifying trip: \(error)")
            return false
        }
    }

    
    func getAllTrips(userID: String) async -> [String: [Trip]] {
        var in_progress_trips: [Trip] = []
        var driven_trips: [Trip] = []
        var future_trips: [Trip] = []
        
        let user = db.collection("USERS").document(userID)
        
        do {
            let trip_document = try await user.getDocument()
            guard let tripDocs = trip_document.data()?["trips"] as? [String] else {
                print("Unable to retrieve trips array from user document")
                return [:]
            }
            
            // Use TaskGroup to fetch and process each trip concurrently
            await withTaskGroup(of: (Trip, Int)?.self) { group in
                for tripID in tripDocs {
                    group.addTask {
                        let tripRef = self.db.collection("TRIPS").document(tripID)
                        
                        do {
                            let tripDoc = try await tripRef.getDocument()
                            guard let tripData = tripDoc.data() else {
                                print("Trip document \(tripID) does not exist or is empty")
                                return nil
                            }
                            
                            let start_location_id = tripData["start_id"] as? String ?? ""
                            let end_location_id = tripData["end_id"] as? String ?? ""
                            let hasDriven = tripData["hasDriven"] as? Int ?? 2
                            
                            // Concurrently fetch start and end locations
                            async let startLocationResult = self.fetchLocationData(from: tripDoc.reference.collection("STOPS").document(start_location_id))
                            async let endLocationResult = self.fetchLocationData(from: tripDoc.reference.collection("STOPS").document(end_location_id))
                            
                            guard let start_location = await startLocationResult,
                                  let end_location = await endLocationResult else {
                                print("Start or end location is missing for trip \(tripID)")
                                return nil
                            }
                            
                            // Fetch stops concurrently for each trip
                            let stops_data = tripData["stops"] as? [String] ?? []
                            var stops: [any POI] = []
                            for stopID in stops_data {
                                async let stopResult = self.fetchLocationData(from: tripDoc.reference.collection("STOPS").document(stopID))
                                if let stop = await stopResult {
                                    stops.append(stop)
                                }
                            }
                            
                            // Create the new trip
                            let newTrip = Trip(
                                id: tripID,
                                start_location: start_location,
                                end_location: end_location,
                                start_date: tripData["start_date"] as? String ?? "",
                                end_date: tripData["end_date"] as? String ?? "",
                                created_date: tripData["created_date"] as? String ?? "",
                                modified_date: tripData["modified_date"] as? String ?? "",
                                stops: stops,
                                start_time: tripData["start_time"] as? String ?? "",
                                name: tripData["name"] as? String ?? "",
                                isPrivate: tripData["isPrivate"] as? Bool ?? true
                            )
                            
                            // Return the trip along with its `hasDriven` status
                            return (newTrip, hasDriven)
                            
                        } catch {
                            print("Error fetching trip \(tripID): \(error)")
                            return nil
                        }
                    }
                }
                
                for await result in group {
                    if let (trip, hasDriven) = result {
                        switch hasDriven {
                        case 0: driven_trips.append(trip)
                        case 1: in_progress_trips.append(trip)
                        case 2: future_trips.append(trip)
                        default: break
                        }
                    }
                }
            }
            
        } catch {
            print("Error fetching user document: \(error)")
            return [:]
        }
        
        return ["past": driven_trips, "present": in_progress_trips, "future": future_trips]
    }


    // Helper function to fetch POI data from a document
    func fetchLocationData(from docRef: DocumentReference) async -> (any POI)? {
        do {
            let doc = try await docRef.getDocument()
            guard let data = doc.data() else { return nil }
            
            return getPOI(
                name: data["name"] as? String ?? "",
                address: data["address"] as? String ?? "",
                type: data["type"] as? String ?? "",
                longitude: data["longitude"] as? Double ?? 0.0,
                latitude: data["latitude"] as? Double ?? 0.0,
                city: data["city"] as? String ?? "",
                cuisine: data["cuisine"] as? String,
                rating: data["rating"] as? Double,
                price: data["price"] as? Int,
                website: data["website"] as? String,
                imageURL: data["imageURL"] as? String
            )
        } catch {
            print("Error fetching location data: \(error)")
            return nil
        }
    }

    
    func storeImageAndReturnURL(image: UIImage, tripID: String, completion: @escaping (URL?) -> Void) {
                print("started")
                guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                    //completion(nil)
                    print("image with url")
                    return
                }
                    // create random image path
                let imagePath = "images/\(UUID().uuidString).jpg"
                let storageRef = Storage.storage().reference()
                // create reference to file you want to upload
                let imageRef = storageRef.child(imagePath)
                var urlString: String = ""
                //upload image
                
                imageRef.putData(imageData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("Error uploading image: \(error.localizedDescription)")
                    } else {
                        // Image successfully uploaded
                        imageRef.downloadURL { url, error in
                            if let downloadURL = url {
                                urlString = downloadURL.absoluteString
                                Task {
                                    await self.addURLToUser(tripID: tripID, urlString: urlString)
                                }
                                completion(url)
                                print("urlString: \(urlString)")
                            } else {
                                print("Error getting download URL: (String(describing: error?.localizedDescription))")
                            }
                        }
                    }
                }
            
                
            }
            
    private func addURLToUser(tripID: String, urlString: String) async -> Void {
        let docRef = db.collection("TRIPS").document(tripID)
        print("tripID = \(tripID)")
        do {
            let document = try await docRef.getDocument()
            guard var images = document.data()?["images"] as? [String] else {
                print("Document does not exist or 'images' is not an array.")
                return
            }
            if (!images.contains(urlString)) {
                images.append(urlString)
                try await db.collection("TRIPS").document(tripID).updateData(["images": images])
                print("updated firebase")
                //return true
                
            } else {
                print("Image already in user image list")
                //return false;
            }
        } catch {
            print(error)
            //return false
        }
    }
    
    func clearTripImages(tripID: String) async -> Void {
        let docRef = db.collection("TRIPS").document(tripID)
        do {
            let document = try await docRef.getDocument()
            guard var images = document.data()?["images"] as? [String] else {
                print("Document does not exist or 'images' is not an array.")
                return
            }
            images.removeAll()
            try await db.collection("TRIPS").document(tripID).updateData(["images": images])
            print("updated firebase")
                //return true
        } catch {
            print(error)
            //return false
        }
    }
        
    func getAllImages(tripID: String) async -> [String] {
        let docRef = db.collection("TRIPS").document(tripID)
        var images_list: [String] = []
        do {
            let document = try await docRef.getDocument()
            guard var images = document.data()?["images"] as? [String] else {
                print("Document does not exist or 'images' is not an array.")
                return images_list
            }
            images_list = images
        } catch {
            print(error)
        }
        return images_list
    }
        
    func getImageFromURL(urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Invalid URL string: \(urlString)")
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error loading image from URL: \(error.localizedDescription)")
                    completion(nil)
                } else if let data = data, let image = UIImage(data: data) {
                    completion(image)
                } else {
                    print("Could not load image from URL: \(urlString)")
                    completion(nil)
                }
            }
        }.resume()
    }

    
    private func getPOI(name: String, address: String, type: String, longitude: Double, latitude: Double, city: String?, cuisine: String? = nil, rating: Double? = nil, price: Int? = nil, website: String? = nil, imageURL: String? = nil) -> any POI {
        switch type {
        case "Restaurant":
            return Restaurant(address: address, name: name, rating: rating, cuisine: cuisine, price: price, website: website, latitude: latitude, longitude: longitude, city: city, imageURL: imageURL)
        case "RestStop":
            return RestStop(address: address, name: name, latitude: latitude, longitude: longitude, city: city, imageURL: imageURL)
        case "GasStation":
            return GasStation(address: address, name: name, latitude: latitude, longitude: longitude, city: city, imageURL: imageURL)
        case "GeneralLocation":
            return GeneralLocation(address: address, name: name, latitude: latitude, longitude: longitude, city: city, imageUrl: imageURL)
        case "Hotel":
            return Hotel(address: address, name: name, rating: rating, website: website, latitude: latitude, longitude: longitude, city: city, imageUrl: imageURL)
        case "Shopping":
            return Shopping(address: address, name: name, latitude: latitude, longitude: longitude, city: city, imageUrl: imageURL)
        case "Activity":
            return Activity(address: address, name: name, latitude: latitude, longitude: longitude, city: city, imageUrl: imageURL)
        default:
            return GeneralLocation(address: address, name: name, latitude: latitude, longitude: longitude, city: city, imageUrl: imageURL)
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
    
    func saveNameAndVisibility(tripID: String, name: String, visibility: Bool) async -> Bool {
        do {
            try await db.collection("TRIPS").document(tripID).updateData(["name": name, "isPrivate": visibility])
            return true
        } catch {
            print(error)
            return false;
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
