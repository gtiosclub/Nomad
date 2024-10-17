//
//  FirebaseTesting.swift
//  FirebaseTesting
//
//  Created by Datta Kansal on 10/17/24.
//

import XCTest
import FirebaseFirestore
@testable import Nomad


final class FirebaseTesting: XCTestCase {
    
    var db: Firestore!
    var vm: FirebaseViewModel!

    override func setUpWithError() throws {
        super.setUp()
        // Initialize Firestore or mock if needed
        db = Firestore.firestore() // Assuming a real Firestore instance
        vm = FirebaseViewModel()
    }

    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        db = nil
        super.tearDown()
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    // MARK: - Test Cases
    
    // 1. Test Case: User with No Trips
    func testGetAllTrips_noTrips() async {
        let userID = "adExED5FHfNSzTr63EC1sSrGaOG2" // Fill in with a valid test userID
        let trips = await vm.getAllTrips(userID: userID)
        
        XCTAssertTrue(trips.isEmpty, "Expected no trips for user with no trips.")
    }

    // 2. Test Case: User with Multiple Trips
    func testGetAllTrips_multipleTrips() async {
        let userID = "test2" // Fill in with a valid test userID
        let trips = await vm.getAllTrips(userID: userID)
        
        XCTAssertFalse(trips.isEmpty, "Expected some trips for this user.")
        XCTAssertEqual(trips.count, 2, "Expected exactly 2 trips.") // Adjust based on how many trips the user should have

        let trip1 = trips[0]
        let trip2 = trips[1]
//        print("Start time trip1 ,\(trip1.getStartTime())")
//        print("Stops trip1, \(trip1.getStops())")
//        print("Start location trip2 \(trip2.getStartLocation().name)")
//        print("Start location name trip2 \(trip2.getStartLocation().address)")
                // Check first trip with no stops
        let trip1count: Bool = (trip1.getStops().count == 2)
        print(trip1count)
        let trip2count: Bool = (trip2.getStops().count == 0)
        print(trip2count)
        XCTAssertTrue(trip1count, "First trip should have 2 stops.")
        XCTAssertTrue(trip2count, "Second trip should have 0 stops.")
    }
//
//    // 3. Test Case: Trip with Missing Stop Data
//    func testGetAllTrips_tripWithMissingStopData() async {
//        let userID = "testUserTripWithMissingStopData" // Fill in with a valid test userID
//        let trips = await vm.getAllTrips(userID: userID)
//
//        XCTAssertFalse(trips.isEmpty, "Expected trips to be returned.")
//
//        let trip = trips[0] // Test the specific trip
//        let stop = trip.stops[0] // Assuming the stop in question is the first stop
//
//        XCTAssertEqual(stop.name, "", "Expected the stop name to be empty when missing.")
//        XCTAssertEqual(stop.address, "", "Expected the stop address to be empty when missing.")
//    }
//
//    // 4. Test Case: Error Handling When Trip Does Not Exist
//    func testGetAllTrips_nonExistentTrip() async {
//        let userID = "testUserWithNonExistentTrip" // Fill in with a valid test userID
//        let trips = await vm.getAllTrips(userID: userID)
//
//        XCTAssertFalse(trips.isEmpty, "Expected at least some trips to be returned.")
//
//        let missingTrip = trips.first { $0.id == "nonExistentTripID" }
//        XCTAssertNil(missingTrip, "Trip with non-existent ID should not be returned.")
//    }
//
//    // 5. Test Case: Partial Data for Start and End Locations
//    func testGetAllTrips_partialStartEndLocationData() async {
//        let userID = "testUserPartialStartEnd" // Fill in with a valid test userID
//        let trips = await vm.getAllTrips(userID: userID)
//
//        XCTAssertFalse(trips.isEmpty, "Expected trips to be returned.")
//
//        let trip = trips[0] // Test the specific trip
//        XCTAssertEqual(trip.start_location.name, "Start Location Name", "Expected correct start location name.")
//        XCTAssertEqual(trip.start_location.address, "", "Expected start location address to be empty when missing.")
//
//        XCTAssertEqual(trip.end_location.name, "End Location Name", "Expected correct end location name.")
//        XCTAssertEqual(trip.end_location.address, "", "Expected end location address to be empty when missing.")
//    }
//
//    // 6. Test Case: Trip with Latitude/Longitude Information
//    func testGetAllTrips_tripWithLatLongData() async {
//        let userID = "testUserWithLatLongData" // Fill in with a valid test userID
//        let trips = await vm.getAllTrips(userID: userID)
//
//        XCTAssertFalse(trips.isEmpty, "Expected trips to be returned.")
//
//        let trip = trips[0] // Test the specific trip
//        let stop = trip.stops[0] // Assuming the first stop has lat/long data
//
//        XCTAssertEqual(stop.latitude, 37.7749, "Expected correct latitude for stop.")
//        XCTAssertEqual(stop.longitude, -122.4194, "Expected correct longitude for stop.")
//    }

}
