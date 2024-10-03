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
//        let expectation = self.expectation(description: "testing ChatGPT API")
//        await vm.getChatGPT() { result in
//            print("Result \(result)")
//            expectation.fulfill()
//        }
//        await waitForExpectations(timeout: 10) {error in
//            if let error = error {
//                print("this function doesn't work")
//            }
//        }
        await print(vm.getChatGPT())
//        expectation.fulfill()
        
//        await waitForExpectations(timeout: 5) {error in
//            if let error = error {
//                print("this function doesn't work")
//            }
//        }
        
    }
    
    func testJsonOutput() async {
        let query = "What are the seven wonders of the world?"
        await print(vm.getJsonOutput(query: query)!)
    }
    
    func testGetRestaurantsInSpecificFormat() async {
        let query = "What are some restuarants in Atlanta that are near the Atlanta Aquarium?"
        await print(vm.getRestaurants(query: query)!)
    }
}
