//
//  AIUnitTesting.swift
//  AIUnitTesting
//
//  Created by Connor on 9/17/24.
//

import XCTest
@testable import Nomad

final class AIUnitTesting: XCTestCase {
    
    var vm: AIAssistantViewModel!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        vm = AIAssistantViewModel()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testFetchBusinesses() async {
        await vm.fetchBusinesses()
    }
    
    func testChatGPT() async {
        await print(vm.getChatGPT())
    }
    
    func testJsonOutput() async {
        let query = "What are the seven wonders of the world?"
        await print(vm.getJsonOutput(query: query)!)
    }
    
    func testParseInputIntoJson() async {
        let query = "What are some restuarants in Atlanta that are near the Atlanta Aquarium?"
        await print(vm.queryChatGPT(query: query)!)
    }
    
    func testGasPrices() async {
//        let expectation = self.expectation(description: "testing Gas API")
        await print(vm.getGasPrices(stateCode: "CT") ?? -1)
//        expectation.fulfill()
        
//        await waitForExpectations(timeout: 5) {error in
//            if let error = error {
//                print("this function doesn't work")
//            }
//        }
    }
        
    func testYelpLocationInitialization() async {
        let location = AIAssistantViewModel.LocationInfo(locationType: "Restaurant", distance: 1200, location: "123 Main St")
        XCTAssertEqual(location.locationType, "Restaurant")
        XCTAssertEqual(location.distance, 1200)
        XCTAssertEqual(location.location, "123 Main St")
    }
    
    func testConvertStringToStruct() {
        let expectedLocation = AIAssistantViewModel.LocationInfo(locationType: "Restaurant", distance: 1200, location: "123 Main St")
        let emptyLocation = AIAssistantViewModel.LocationInfo(locationType: "", distance: -1, location: "")

        let jsonString = """
        {
            "locationType": "Restaurant",
            "distance": 1200,
            "location": "123 Main St"
        }
        """
        let convertedLocation = vm.convertStringToStruct(jsonString: jsonString)
        print("Expected Location: \(expectedLocation)")
        print("Converted Location: \(String(describing: convertedLocation))")
        XCTAssertNotEqual(convertedLocation, emptyLocation)
        XCTAssertEqual(expectedLocation, convertedLocation)
        XCTAssertEqual(convertedLocation?.locationType, "Restaurant")
        XCTAssertEqual(convertedLocation?.distance, 1200)
        XCTAssertEqual(convertedLocation?.location, "123 Main St")

    }
    
    func testCallYelpAfterQuery() async {
        let query = "What are some restuarants in Atlanta that are a mile away from the Atlanta Aquarium?"
        let jsonString = await vm.queryChatGPT(query: query) ?? ""
        XCTAssertNotNil(jsonString)
        let convertedLocation = vm.convertStringToStruct(jsonString: jsonString)
        XCTAssertNotNil(convertedLocation)
        let businesses = await vm.queryYelp(jsonString: jsonString) ?? "!!!Failed!!!"
        XCTAssertNotNil(businesses)
        print(businesses)
    }
    
    func testAPIKeys() async {
        let newVm = AIAssistantViewModel()
//        print("Gas key \(newVm.gasPricesAPIKey)")
//        print("OpenAI key \(newVm.openAIAPIKey)")
//        print("Yelp key \(newVm.yelpAPIKey)")
    }
    
}
