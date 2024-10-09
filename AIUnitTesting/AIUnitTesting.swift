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
        let query = "What are some restuarants in Atlanta that are a mile away from the Georgia Institute of Technology?"

        let jsonString = await vm.queryChatGPT(query: query) ?? ""
        XCTAssertNotNil(jsonString)
        let businesses = await vm.queryYelpWithjSONString(jsonString: jsonString) ?? "!!!Failed!!!"
        XCTAssertNotNil(businesses)
        print(businesses)
    }
    
    func testConverseAndGetInfoFromYelp() async {
        let query = "What are some restuarants in New York City that are two miles away from The Empire State Building?"
        let businesses = await vm.converseAndGetInfoFromYelp(query: query) ?? ""
        XCTAssertNotNil(businesses)
        print("Test Converse And Get Info From Yelp: \(businesses)")
    }
    
    func testParsingYelpRestaurantIntoModel() async {
        let yelpData = """
        
            {"businesses": [{"id": "GJxFtnTqTiokFedNrW9iDQ", "alias": "atlanta-breakfast-club-atlanta", "name": "Atlanta Breakfast Club", "image_url": "https://s3-media1.fl.yelpcdn.com/bphoto/tBskU517-2-G7VSgac6a5w/o.jpg", "is_closed": false, "url": "https://www.yelp.com/biz/atlanta-breakfast-club-atlanta?adjust_creative=esW3iDi0HV9ZWuH7EG8y6A&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=esW3iDi0HV9ZWuH7EG8y6A", "review_count": 7413, "categories": [{"alias": "southern", "title": "Southern"}, {"alias": "breakfast_brunch", "title": "Breakfast & Brunch"}, {"alias": "tradamerican", "title": "American"}], "rating": 4.5, "coordinates": {"latitude": 33.7649, "longitude": -84.39546}, "transactions": ["delivery", "pickup"], "price": "$$", "location": {"address1": "249 Ivan Allen Jr Blvd", "address2": "", "address3": "", "city": "Atlanta", "zip_code": "30313", "country": "US", "state": "GA", "display_address": ["249 Ivan Allen Jr Blvd", "Atlanta, GA 30313"]}, "phone": "+14704283825", "display_phone": "(470) 428-3825", "distance": 159.76731209075209, "business_hours": [{"open": [{"is_overnight": false, "start": "0630", "end": "1500", "day": 0}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 1}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 2}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 3}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 4}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 5}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 6}], "hours_type": "REGULAR", "is_open_now": false}], "attributes": {"business_temp_closed": null, "menu_url": "https://www.atlbreakfastclub.com/menu", "open24_hours": null, "waitlist_reservation": true}}], "total": 240, "region": {"center": {"longitude": -84.39525604248047, "latitude": 33.763440105095704}}}

        """
        let businessResponse = vm.parseGetBusinessesIntoModel(yelpInfo: yelpData) ?? nil
        XCTAssertNotNil(businessResponse)
        XCTAssertEqual(businessResponse?.businesses.first?.id, "GJxFtnTqTiokFedNrW9iDQ")
        XCTAssertEqual(businessResponse?.businesses.first?.name, "Atlanta Breakfast Club")
        XCTAssertEqual(businessResponse?.businesses.first?.location.address1, "249 Ivan Allen Jr Blvd") //
        print(businessResponse ?? "")
    }
    
    func testFormatResponseToUser() async {
        let response = await vm.formatResponseToUser(name: "Atlanta Breakfast Club", address: "249 Ivan Allen Jr Blvd", price: "$$", rating: 4.5, phoneNumber: "+14704283825") ?? ""
        XCTAssertNotEqual("", response)
        print(response)
    }
    
    
    
}
