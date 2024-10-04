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
                let db = Firestore.firestore()
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
}
