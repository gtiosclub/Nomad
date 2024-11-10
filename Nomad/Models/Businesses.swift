//
//  Businesses.swift
//  Nomad
//
//  Created by Connor on 10/8/24.
//

import Foundation


struct BusinessResponse: Codable {
    let businesses: [YelpBusiness]
}

struct YelpBusiness: Codable, Identifiable {
    let id: String
    let alias: String
    let name: String
    let imageUrl: String?
    let isClosed: Bool?
    let url: String?
    let reviewCount: Int?
    let categories: [YelpCategory]?
    let rating: Double?
    let coordinates: YelpCoordinates
    let transactions: [String]?
    let price: String?
    let location: YelpLocation
    let phone: String
    let displayPhone: String
    let distance: Double?
    let businessHours: [BusinessHours]
    let attributes: Attributes
    
    enum CodingKeys: String, CodingKey {
        case id, alias, name, url, rating, coordinates, transactions, price, location, phone, distance, attributes
        case imageUrl = "image_url"
        case isClosed = "is_closed"
        case reviewCount = "review_count"
        case displayPhone = "display_phone"
        case businessHours = "business_hours"
        case categories
    }
}

struct YelpCategory: Codable {
    let alias: String
    let title: String
}

struct YelpCoordinates: Codable {
    let latitude: Double
    let longitude: Double
}

struct YelpLocation: Codable {
    let address1: String
    let address2: String?
    let address3: String?
    let city: String
    let zipCode: String
    let country: String
    let state: String
    let displayAddress: [String]
    
    enum CodingKeys: String, CodingKey {
        case address1, address2, address3, city, country, state
        case zipCode = "zip_code"
        case displayAddress = "display_address"
    }
}

struct BusinessHours: Codable {
    let open: [OpenHours]
    let hoursType: String
    let isOpenNow: Bool
    
    enum CodingKeys: String, CodingKey {
        case open, hoursType = "hours_type", isOpenNow = "is_open_now"
    }
}

struct OpenHours: Codable {
    let isOvernight: Bool
    let start: String
    let end: String
    let day: Int
    
    enum CodingKeys: String, CodingKey {
        case isOvernight = "is_overnight"
        case start, end, day
    }
}

struct Attributes: Codable {
    let businessTempClosed: Bool?
    let menuUrl: String?
    let open24Hours: Bool?
    let waitlistReservation: Bool?
    
    enum CodingKeys: String, CodingKey {
        case businessTempClosed = "business_temp_closed"
        case menuUrl = "menu_url"
        case open24Hours = "open24_hours"
        case waitlistReservation = "waitlist_reservation"
    }
}
