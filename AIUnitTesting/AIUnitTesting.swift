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
        let location = AIAssistantViewModel.LocationInfo(locationType: "Restaurant", locationInformation: "", distance: 1200, time: 0.0, price: "1,2,3,4", location: "123 Main St", preferences: [])
        XCTAssertEqual(location.locationType, "Restaurant")
        XCTAssertEqual(location.distance, 1200)
        XCTAssertEqual(location.location, "123 Main St")
    }
    
    func testConvertStringToStruct() {
        let expectedLocation = AIAssistantViewModel.LocationInfo(locationType: "Restaurant", locationInformation: "", distance: 1200, time: 0.0, price: "1,2,3,4", location: "123 Main St", preferences: [])
        let emptyLocation = AIAssistantViewModel.LocationInfo(locationType: "", locationInformation: "", distance: -1, time: 0.0, price: "1,2,3,4", location: "", preferences: [])

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
    
    func testFetchSpecificBusinesses() async {
        let locationType = "Restaurant"
        let distance = 1.0
        let price = "2"
        let location = "Georgia Institute of Technology"
        let preferences = ""
        
        let businessesJSONString = await vm.fetchSpecificBusinesses(locationType: locationType, distance: distance, price: price, location: location, preferences: preferences)
        print("Test testFetchSpecificBusinesses \(businessesJSONString!)")
    }
    
    func testCallYelpAfterQuery() async {
        let query = "What are some restuarants in Atlanta that are a mile away from the Georgia Institute of Technology?"

        let jsonString = await vm.queryChatGPT(query: query) ?? ""
        XCTAssertNotNil(jsonString)
        XCTAssertNotEqual(jsonString, "")
//        await print("Test testCallYelpAfterQuery: jsonString = \(vm.queryChatGPT(query: query)!)")
        let businesses = await vm.queryYelpWithjSONString(jsonString: jsonString) ?? "!!!Failed!!!"
        XCTAssertNotNil(businesses)
        print("Test testCallYelpAfterQuery: \(businesses)")
    }
    
    func testParseYelpRestuarantsIntoModelFullStack() async {
        let query = "What are some restuarants in Atlanta that are a mile away from the Georgia Institute of Technology?"

        let jsonString = await vm.queryChatGPT(query: query) ?? ""
        XCTAssertNotNil(jsonString)
        XCTAssertNotEqual(jsonString, "")
//        await print("Test testCallYelpAfterQuery: jsonString = \(vm.queryChatGPT(query: query)!)")
        let yelpData = await vm.queryYelpWithjSONString(jsonString: jsonString) ?? "!!!Failed!!!"
        XCTAssertNotNil(yelpData)
        let businesses = vm.parseGetBusinessesIntoModel(yelpInfo: yelpData) ?? nil
        print("Test testCallYelpAfterQuery: \(String(describing: businesses))")
    }
    
    func testConverseAndGetInfoFromYelp() async {
        let query = "What are some restuarants in Atlanta that are a mile away from the Georgia Institute of Technology?"
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
        print("testParsingYelpRestaurantIntoModel \(String(describing: businessResponse))")
    }
    
    func testMultipleParseYelpRestaurantIntoModel() async {
        let yelpData = """
            
            {"businesses": [{"id": "eG-UO83g_5zDk70FIJbm2w", "alias": "south-city-kitchen-midtown-atlanta-2", "name": "South City Kitchen Midtown", "image_url": "https://s3-media3.fl.yelpcdn.com/bphoto/L1qX2ttHqvNMqgsw_JQNLQ/o.jpg", "is_closed": false, "url": "https://www.yelp.com/biz/south-city-kitchen-midtown-atlanta-2?adjust_creative=CKngfcYEdt1b_kbFVetUaA&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=CKngfcYEdt1b_kbFVetUaA", "review_count": 3407, "categories": [{"alias": "southern", "title": "Southern"}], "rating": 4.4, "coordinates": {"latitude": 33.78596777974661, "longitude": -84.3844341}, "transactions": ["delivery"], "price": "$$", "location": {"address1": "1144 Crescent Ave NE", "address2": "", "address3": "", "city": "Atlanta", "zip_code": "30309", "country": "US", "state": "GA", "display_address": ["1144 Crescent Ave NE", "Atlanta, GA 30309"]}, "phone": "+14048737358", "display_phone": "(404) 873-7358", "distance": 1581.230096397513, "business_hours": [{"open": [{"is_overnight": false, "start": "1100", "end": "1430", "day": 0}, {"is_overnight": false, "start": "1700", "end": "2130", "day": 0}, {"is_overnight": false, "start": "1100", "end": "1430", "day": 1}, {"is_overnight": false, "start": "1700", "end": "2130", "day": 1}, {"is_overnight": false, "start": "1100", "end": "1400", "day": 2}, {"is_overnight": false, "start": "1700", "end": "2100", "day": 2}, {"is_overnight": false, "start": "1100", "end": "1430", "day": 3}, {"is_overnight": false, "start": "1700", "end": "2130", "day": 3}, {"is_overnight": false, "start": "1100", "end": "1430", "day": 4}, {"is_overnight": false, "start": "1700", "end": "2200", "day": 4}, {"is_overnight": false, "start": "1000", "end": "1500", "day": 5}, {"is_overnight": false, "start": "1700", "end": "2200", "day": 5}, {"is_overnight": false, "start": "1000", "end": "1500", "day": 6}, {"is_overnight": false, "start": "1700", "end": "2100", "day": 6}], "hours_type": "REGULAR", "is_open_now": true}], "attributes": {"business_temp_closed": null, "menu_url": "https://www.southcitykitchen.com/midtown-menus/", "open24_hours": null, "waitlist_reservation": null}}, {"id": "GJxFtnTqTiokFedNrW9iDQ", "alias": "atlanta-breakfast-club-atlanta", "name": "Atlanta Breakfast Club", "image_url": "https://s3-media1.fl.yelpcdn.com/bphoto/tBskU517-2-G7VSgac6a5w/o.jpg", "is_closed": false, "url": "https://www.yelp.com/biz/atlanta-breakfast-club-atlanta?adjust_creative=CKngfcYEdt1b_kbFVetUaA&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=CKngfcYEdt1b_kbFVetUaA", "review_count": 7465, "categories": [{"alias": "southern", "title": "Southern"}, {"alias": "breakfast_brunch", "title": "Breakfast & Brunch"}, {"alias": "tradamerican", "title": "American"}], "rating": 4.5, "coordinates": {"latitude": 33.7649, "longitude": -84.39546}, "transactions": ["pickup", "delivery"], "price": "$$", "location": {"address1": "249 Ivan Allen Jr Blvd", "address2": "", "address3": "", "city": "Atlanta", "zip_code": "30313", "country": "US", "state": "GA", "display_address": ["249 Ivan Allen Jr Blvd", "Atlanta, GA 30313"]}, "phone": "+14704283825", "display_phone": "(470) 428-3825", "distance": 1208.43030557668, "business_hours": [{"open": [{"is_overnight": false, "start": "0630", "end": "1500", "day": 0}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 1}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 2}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 3}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 4}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 5}, {"is_overnight": false, "start": "0630", "end": "1500", "day": 6}], "hours_type": "REGULAR", "is_open_now": false}], "attributes": {"business_temp_closed": null, "menu_url": "https://www.atlbreakfastclub.com/menu", "open24_hours": null, "waitlist_reservation": true}}, {"id": "tDv2qG4N7PsYLN0QYuuaZQ", "alias": "bulla-gastrobar-atlanta-4", "name": "Bulla Gastrobar", "image_url": "https://s3-media2.fl.yelpcdn.com/bphoto/DM5rELgalO4wUJUyJEnuDQ/o.jpg", "is_closed": false, "url": "https://www.yelp.com/biz/bulla-gastrobar-atlanta-4?adjust_creative=CKngfcYEdt1b_kbFVetUaA&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=CKngfcYEdt1b_kbFVetUaA", "review_count": 1025, "categories": [{"alias": "spanish", "title": "Spanish"}, {"alias": "gastropubs", "title": "Gastropubs"}, {"alias": "tapas", "title": "Tapas Bars"}], "rating": 4.3, "coordinates": {"latitude": 33.78350790384358, "longitude": -84.3853003705523}, "transactions": ["pickup", "delivery"], "price": "$$", "location": {"address1": "60 11th St NE", "address2": "", "address3": null, "city": "Atlanta", "zip_code": "30309", "country": "US", "state": "GA", "display_address": ["60 11th St NE", "Atlanta, GA 30309"]}, "phone": "+14049006926", "display_phone": "(404) 900-6926", "distance": 1335.0310727104777, "business_hours": [{"open": [{"is_overnight": false, "start": "1130", "end": "2200", "day": 0}, {"is_overnight": false, "start": "1130", "end": "2200", "day": 1}, {"is_overnight": false, "start": "1130", "end": "2200", "day": 2}, {"is_overnight": false, "start": "1130", "end": "2200", "day": 3}, {"is_overnight": false, "start": "1130", "end": "2300", "day": 4}, {"is_overnight": false, "start": "1100", "end": "2300", "day": 5}, {"is_overnight": false, "start": "1100", "end": "2200", "day": 6}], "hours_type": "REGULAR", "is_open_now": true}], "attributes": {"business_temp_closed": null, "menu_url": "https://bullagastrobar.com/menus/atlanta/", "open24_hours": null, "waitlist_reservation": null}}], "total": 116, "region": {"center": {"longitude": -84.39628601074219, "latitude": 33.7757121834046}}}
        
        """
        let businessResponse = vm.parseGetBusinessesIntoModel(yelpInfo: yelpData) ?? nil
        XCTAssertNotNil(businessResponse)
        XCTAssertEqual(businessResponse?.businesses.first?.id, "eG-UO83g_5zDk70FIJbm2w")
        XCTAssertEqual(businessResponse?.businesses.first?.name, "South City Kitchen Midtown")
        XCTAssertEqual(businessResponse?.businesses.first?.location.address1, "1144 Crescent Ave NE") //
        
        XCTAssertEqual(businessResponse?.businesses[1].id, "GJxFtnTqTiokFedNrW9iDQ")
        XCTAssertEqual(businessResponse?.businesses[1].name, "Atlanta Breakfast Club")
        XCTAssertEqual(businessResponse?.businesses[1].location.address1, "249 Ivan Allen Jr Blvd")
        
        XCTAssertEqual(businessResponse?.businesses[2].id, "tDv2qG4N7PsYLN0QYuuaZQ")
        XCTAssertEqual(businessResponse?.businesses[2].name, "Bulla Gastrobar")
        XCTAssertEqual(businessResponse?.businesses[2].location.address1, "60 11th St NE")
        print("testParsingYelpRestaurantIntoModel \(String(describing: businessResponse))")
    }
    
    func testFormatResponseToUser() async {
        let response = await vm.formatResponseToUser(name: "Atlanta Breakfast Club", address: "249 Ivan Allen Jr Blvd", price: "$$", rating: 4.5, phoneNumber: "+14704283825") ?? ""
        XCTAssertNotEqual("", response)
        print(response)
    }
    
    func testGetPOIDetails() async {
        let query = "What are some restuarants in Atlanta that are a mile away from the Georgia Institute of Technology?"
        let poiDetails = await vm.getPOIDetails(query: query) ?? [POIDetail.null]
        XCTAssertNotNil(poiDetails)
        print("""
            Test GetPOIDetails:
            First POI: \(String(describing: poiDetails.first))
            First Name: \(String(describing: poiDetails.first?.name))
            POI Details: \(poiDetails)
        """)
    }
    
    
    func testFetchAPIKeys() {
            // Create an instance of your ViewModel
            let viewModel = AIAssistantViewModel()
            
            // Create an expectation
            let expectation = self.expectation(description: "Fetch API Keys")

            // Wait for the API keys to be fetched
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Adjust the time if needed
                // Assert the expected values
                XCTAssertNotNil(viewModel.openAIAPIKey)
                XCTAssertNotNil(viewModel.yelpAPIKey)
                XCTAssertNotNil(viewModel.gasPricesAPIKey)

                // Fulfill the expectation
                expectation.fulfill()
            }

            // Wait for expectations to be fulfilled
            waitForExpectations(timeout: 5, handler: nil)
        }
    
}
