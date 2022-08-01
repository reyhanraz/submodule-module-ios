//
//  PostBookingRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 15/07/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation
public struct PostBookingRequest: Encodable {
    public let artisanId: String
    public let eventName: String
    public let start: String
    public let bookingServiceRequests: [ServiceRequest]
    public let venue: Venue?
    public let note: String?
    
    public let addressId: Int?
    public let addressName: String?
    public let addressDetail: String?
    public let areaId: Int?
    public let lat: Double?
    public let lon: Double?
    
    public init(artisanId: String, addressId: Int? = nil, addressName: String?, addressDetail: String?, areaId: Int? = nil, eventName: String, start: String, lat: Double?, lon: Double?, bookingServiceRequests: [ServiceRequest]) {
        self.artisanId = artisanId
        self.addressId = addressId
        self.addressName = addressName
        self.addressDetail = addressDetail
        self.areaId = areaId
        self.eventName = eventName
        self.start = start
        self.lat = lat
        self.lon = lon
        self.bookingServiceRequests = bookingServiceRequests
        self.venue = nil
        self.note = nil
    }
    
    public init(artisanId: String, bookingServiceRequests: [ServiceRequest], eventName: String, note: String?, start: String, addressName: String?, addressNote: String?, lat: Double?, lon: Double?, address: String?, rawAddress: [String:String]? = [:]){
        self.artisanId = artisanId
        self.eventName = eventName
        self.note = note
        self.start = start
        self.bookingServiceRequests = bookingServiceRequests
        self.venue = Venue(name: addressName,
                           location: Venue.Location(latitude: lat, longitude: lon, address: address),
                           note: addressNote,
                           rawAddress: rawAddress)

        self.addressId = nil
        self.addressName = nil
        self.addressDetail = nil
        self.areaId = nil
        self.lat = nil
        self.lon = nil

    }

    enum CodingKeys: String, CodingKey {
        case artisanId
        case addressId
        case addressDetail
        case eventName
        case start
        case bookingServiceRequests
        case venue
    }
    
    public struct ServiceRequest: Encodable {
        public let serviceId: String
        public let quantity: Int
        public let note: String?
        
        public init(serviceId: String, quantity: Int, note: String?){
            self.serviceId = serviceId
            self.quantity = quantity
            self.note = note
        }
    }
    
    public struct Venue: Encodable{
        public let name: String?
        public let location: Location?
        public let note: String?
        public let rawAddress: [String: String]?
        
        public struct Location: Encodable{
            public let latitude: Double?
            public let longitude: Double?
            public let address: String?
            
            enum CodingKeys: String, CodingKey{
                case latitude
                case longitude
                case address
            }

        }
        
        enum CodingKeys: String, CodingKey{
            case name
            case note
            case rawAddress
            case location
        }
        
    }
}
