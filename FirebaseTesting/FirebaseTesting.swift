////
////  FirebaseTesting.swift
////  Nomad
////
////  Created by Datta Kansal on 10/17/24.
////
//
//import XCTest
//import Firebase
//@testable import Nomad
//
//
//final class FirebaseTesting: XCTestCase {
//    
//    var db: Firestore!
//    var vm: FirebaseViewModel!
//
//    override func setUpWithError() throws {
//        super.setUp()
//        // Initialize Firestore or mock if needed
//        db = Firestore.firestore() // Assuming a real Firestore instance
//        vm = FirebaseViewModel()
//    }
//
//    
//    override func tearDownWithError() throws {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        db = nil
//        super.tearDown()
//    }
//
//    func testExample() throws {
//        // This is an example of a functional test case.
//        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        // Any test you write for XCTest can be annotated as throws and async.
//        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
//        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
//    }
//
//    func testPerformanceExample() throws {
//        // This is an example of a performance test case.
//        measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//    
//    // MARK: - Test Cases
//    
//    // 1. Test Case: User with No Trips
//    func testGetAllTrips_noTrips() async {
//        let userID = "adExED5FHfNSzTr63EC1sSrGaOG2" // Fill in with a valid test userID
//        let trips = await vm.getAllTrips(userID: userID)
//        print("Hey!")
//        XCTAssertTrue(trips.isEmpty, "Expected no trips for user with no trips.")
//    }
//
//    // 2. Test Case: User with Multiple Trips
////    func testGetAllTrips_multipleTrips() async {
////        let userID = "test2" // Fill in with a valid test userID
////        let trips = await vm.getAllTrips(userID: userID)
////        
////        XCTAssertFalse(trips.isEmpty, "Expected some trips for this user.")
////        XCTAssertEqual(trips.count, 2, "Expected exactly 2 trips.") // Adjust based on how many trips the user should have
////
////        let trip1 = trips[0]
////        let trip2 = trips[1]
//////        print("Start time trip1 ,\(trip1.getStartTime())")
//////        print("Stops trip1, \(trip1.getStops())")
//////        print("Start location trip2 \(trip2.getStartLocation().name)")
//////        print("Start location name trip2 \(trip2.getStartLocation().address)")
////                // Check first trip with no stops
////        let trip1count: Bool = (trip1.getStops().count == 2)
////        print(trip1count)
////        let trip2count: Bool = (trip2.getStops().count == 0)
////        print(trip2count)
////        XCTAssertTrue(trip1count, "First trip should have 2 stops.")
////        XCTAssertTrue(trip2count, "Second trip should have 0 stops.")
////    }
////    
//    func testAddStopToTrip() async throws {
//        var result: Bool = await vm.addStopToTrip(tripID: "testTrip", stop: GasStation(name: "Gas Station", address: "gass street", longitude: 20.5, latitude: 30.3), index: 0)
//        print("done")
//        XCTAssertTrue(result)
//    }
//        
//    func testRemoveStopFromTrip() async throws {
//        var result: Bool = await vm.removeStopFromTrip(tripID: "testTrip", stop: GasStation(name: "Gas Station", address: "gass street", longitude: 20.5, latitude: 30.3))
//        print("done")
//        XCTAssertTrue(result)
//    }
//        
//    func testUpdateStart() async throws{
//        var result: Bool = await vm.modifyStartLocationAndDate(tripID: "testTrip", start: GeneralLocation(address: "North Ave", name: "Marta", latitude: 30.3, longitude: 40.2), modifiedDate: "10/22/24")
//        print("done")
//        XCTAssertTrue(result)
//    }
//        
//    func testUpdateEnd() async throws{
//        var result: Bool = await vm.modifyEndLocationAndDate(tripID: "testTrip", stop: GasStation(name: "quicktrip", address: "broadway", longitude: 50.1, latitude: 0.53), modifiedDate: "10/22/24")
//        print("done")
//        XCTAssertTrue(result)
//    }
//    
//    func testAddStopNoTrip() async throws {
//        var result: Bool = await vm.addStopToTrip(tripID: "madeUpTrip", stop: GasStation(name: "Gas Station", address: "gass street", longitude: 20.5, latitude: 30.3), index: 0)
//        XCTAssertFalse(result)
//    }
//    
//    func testAddStopDuplicate() async throws {
//        var result: Bool = await vm.addStopToTrip(tripID: "testTrip", stop: GasStation(name: "Gas Station", address: "gass street", longitude: 20.5, latitude: 30.3), index: 0)
//        var result2: Bool = await vm.addStopToTrip(tripID: "testTrip", stop: GasStation(name: "Gas Station", address: "gass street", longitude: 20.5, latitude: 30.3), index: 0)
//        XCTAssertFalse(result2)
//    }
//    
//    func testRemoveStopNoTrip() async throws {
//        var result: Bool = await vm.removeStopFromTrip(tripID: "madeUpStop", stop: GasStation(name: "Gas Station", address: "gass street", longitude: 20.5, latitude: 30.3))
//        print("done")
//        XCTAssertFalse(result)
//    }
//    
//    func testRemoveStopNoStop() async throws {
//        var result: Bool = await vm.removeStopFromTrip(tripID: "testTrip", stop: GasStation(name: "madeUpStop", address: "gass street", longitude: 20.5, latitude: 30.3))
//        print("done")
//        XCTAssertFalse(result)
//    }
//    
//    func testModifyStartNoTrip() async throws {
//        var result: Bool = await vm.modifyStartLocationAndDate(tripID: "noTrip", start: GeneralLocation(address: "North Ave", name: "Marta", latitude: 30.3, longitude: 40.2), modifiedDate: "10/22/24")
//        print("done")
//        XCTAssertFalse(result)
//    }
//    
//    func testModifyEndNoTrip() async throws {
//        var result: Bool = await vm.modifyEndLocationAndDate(tripID: "noTrip", stop: GasStation(name: "quicktrip", address: "broadway", longitude: 50.1, latitude: 0.53), modifiedDate: "10/22/24")
//        print("done")
//        XCTAssertFalse(result)
//    }
//    
//    func testReorderStopArray() async throws {
//        var stop1 = Restaurant(address: "London Ave", name: "Five Guys", latitude: 20, longitude: 20)
//        var stop2 = GeneralLocation(address: "Moreland Ave", name: "Target", latitude: 20, longitude: 20)
//        var stop3 = RestStop(address: "I85 Exit 2", name: "Welcome Stop", latitude: 20, longitude: 20)
//        var tripID = "testTrip"
//        await vm.addStopToTrip(tripID: tripID, stop: stop1, index: 0)
//        await vm.addStopToTrip(tripID: tripID, stop: stop2, index: 1)
//        await vm.addStopToTrip(tripID: tripID, stop: stop3, index: 2)
//        var stopReordered = [stop3.name, stop2.name, stop1.name]
//        var result = await vm.updateStopArray(tripID: tripID, stops: stopReordered)
//        XCTAssertTrue(result)
//    }
//    
//    func testReorderStopArrayExtraStop() async throws {
//        var stop1 = Restaurant(address: "London Ave", name: "Five Guys", latitude: 20, longitude: 20)
//        var stop2 = GeneralLocation(address: "Moreland Ave", name: "Target", latitude: 20, longitude: 20)
//        var stop3 = RestStop(address: "I85 Exit 2", name: "Welcome Stop", latitude: 20, longitude: 20)
//        var stop4 = GasStation(name: "not added", address: "irrelevant", longitude: 20, latitude: 20, city: "makebelieveland")
//        var tripID = "testTrip"
//        await vm.addStopToTrip(tripID: tripID, stop: stop1, index: 0)
//        await vm.addStopToTrip(tripID: tripID, stop: stop2, index: 1)
//        await vm.addStopToTrip(tripID: tripID, stop: stop3, index: 2)
//        var stopReordered = [stop3.name, stop2.name, stop1.name, stop4.name]
//        var result = await vm.updateStopArray(tripID: tripID, stops: stopReordered)
//        XCTAssertFalse(result)
//    }
//    
//    func testReorderStopArrayMissingStop() async throws {
//        var stop1 = Restaurant(address: "London Ave", name: "Five Guys", latitude: 20, longitude: 20)
//        var stop2 = GeneralLocation(address: "Moreland Ave", name: "Target", latitude: 20, longitude: 20)
//        var stop3 = RestStop(address: "I85 Exit 2", name: "Welcome Stop", latitude: 20, longitude: 20)
//        var tripID = "testTrip"
//        await vm.addStopToTrip(tripID: tripID, stop: stop1, index: 0)
//        await vm.addStopToTrip(tripID: tripID, stop: stop2, index: 1)
//        await vm.addStopToTrip(tripID: tripID, stop: stop3, index: 2)
//        var stopReordered = [stop3.name, stop2.name]
//        var result = await vm.updateStopArray(tripID: tripID, stops: stopReordered)
//        XCTAssertFalse(result)
//    }
//    
//    func testReorderStopArrayDuplicates() async throws {
//        var stop1 = Restaurant(address: "London Ave", name: "Five Guys", latitude: 20, longitude: 20)
//        var stop2 = GeneralLocation(address: "Moreland Ave", name: "Target", latitude: 20, longitude: 20)
//        var stop3 = RestStop(address: "I85 Exit 2", name: "Welcome Stop", latitude: 20, longitude: 20)
//        var tripID = "testTrip"
//        await vm.addStopToTrip(tripID: tripID, stop: stop1, index: 0)
//        await vm.addStopToTrip(tripID: tripID, stop: stop2, index: 1)
//        await vm.addStopToTrip(tripID: tripID, stop: stop3, index: 2)
//        var stopReordered = [stop3.name, stop2.name, stop1.name, stop2.name]
//        var result = await vm.updateStopArray(tripID: tripID, stops: stopReordered)
//        XCTAssertFalse(result)
//    }
//
//func testAddStopNegIndex() async throws {
//        var result: Bool = await vm.addStopToTrip(tripID: "testTrip", stop: GasStation(name: "Gas Station", address: "gass street", longitude: 20.5, latitude: 30.3), index: -1)
//        XCTAssertFalse(result)
//    }
//    
//    func testAddStopInvalidIndex() async throws {
//        var result: Bool = await vm.addStopToTrip(tripID: "testTrip", stop: GasStation(name: "Gas Station", address: "gass street", longitude: 20.5, latitude: 30.3), index: 10)
//        XCTAssertFalse(result)
//    }
////
////    // 3. Test Case: Trip with Missing Stop Data
////    func testGetAllTrips_tripWithMissingStopData() async {
////        let userID = "testUserTripWithMissingStopData" // Fill in with a valid test userID
////        let trips = await vm.getAllTrips(userID: userID)
////
////        XCTAssertFalse(trips.isEmpty, "Expected trips to be returned.")
////
////        let trip = trips[0] // Test the specific trip
////        let stop = trip.stops[0] // Assuming the stop in question is the first stop
////
////        XCTAssertEqual(stop.name, "", "Expected the stop name to be empty when missing.")
////        XCTAssertEqual(stop.address, "", "Expected the stop address to be empty when missing.")
////    }
////
////    // 4. Test Case: Error Handling When Trip Does Not Exist
////    func testGetAllTrips_nonExistentTrip() async {
////        let userID = "testUserWithNonExistentTrip" // Fill in with a valid test userID
////        let trips = await vm.getAllTrips(userID: userID)
////
////        XCTAssertFalse(trips.isEmpty, "Expected at least some trips to be returned.")
////
////        let missingTrip = trips.first { $0.id == "nonExistentTripID" }
////        XCTAssertNil(missingTrip, "Trip with non-existent ID should not be returned.")
////    }
////
////    // 5. Test Case: Partial Data for Start and End Locations
////    func testGetAllTrips_partialStartEndLocationData() async {
////        let userID = "testUserPartialStartEnd" // Fill in with a valid test userID
////        let trips = await vm.getAllTrips(userID: userID)
////
////        XCTAssertFalse(trips.isEmpty, "Expected trips to be returned.")
////
////        let trip = trips[0] // Test the specific trip
////        XCTAssertEqual(trip.start_location.name, "Start Location Name", "Expected correct start location name.")
////        XCTAssertEqual(trip.start_location.address, "", "Expected start location address to be empty when missing.")
////
////        XCTAssertEqual(trip.end_location.name, "End Location Name", "Expected correct end location name.")
////        XCTAssertEqual(trip.end_location.address, "", "Expected end location address to be empty when missing.")
////    }
////
////    // 6. Test Case: Trip with Latitude/Longitude Information
////    func testGetAllTrips_tripWithLatLongData() async {
////        let userID = "testUserWithLatLongData" // Fill in with a valid test userID
////        let trips = await vm.getAllTrips(userID: userID)
////
////        XCTAssertFalse(trips.isEmpty, "Expected trips to be returned.")
////
////        let trip = trips[0] // Test the specific trip
////        let stop = trip.stops[0] // Assuming the first stop has lat/long data
////
////        XCTAssertEqual(stop.latitude, 37.7749, "Expected correct latitude for stop.")
////        XCTAssertEqual(stop.longitude, -122.4194, "Expected correct longitude for stop.")
////    }
//
//}
