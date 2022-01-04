//
//  PostCustomRequest.swift
//  Booking
//
//  Created by Fandy Gotama on 15/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

public struct PostCustomRequest: Encodable {
    public let id: Int?
    public let addressId: Int?
    public let addressName: String?
    public let addressDetail: String?
    public let lat: Double?
    public let lon: Double?
    public let areaId: Int?
    public let eventName: String
    public let start: String
    public let note: String?
    public let customRequestServiceRequests: [ServiceRequest]
    public let venue: Venue?
    
    public init(id: Int?, addressId: Int?, addressName: String?, addressDetail: String?, areaId: Int?, lat: Double?, lon: Double?, eventName: String, start: String, note: String?, bookingServiceRequests: [ServiceRequest]) {
        self.id = id
        self.addressId = addressId
        self.addressName = addressName
        self.addressDetail = addressDetail
        self.areaId = areaId
        self.lat = lat
        self.lon = lon
        self.eventName = eventName
        self.start = start
        self.note = note
        self.venue = nil
        self.customRequestServiceRequests = bookingServiceRequests
    }
    
    public init(id: Int?, eventName: String, eventNote: String?, start: String, bookingServiceRequests: [ServiceRequest], venueName: String?, latitude: Double?, longitude: Double?, address: String?, venueNote: String?, rawAddress: [String: String]? = nil){
        self.id = id
        self.eventName = eventName
        self.note = eventNote
        self.start = start
        self.customRequestServiceRequests = bookingServiceRequests
        self.venue = Venue(name: venueName,
                           location: Venue.Location(latitude: latitude, longitude: longitude, address: address),
                           note: venueNote,
                           rawAddress: rawAddress)
        self.addressId = nil
        self.addressName = nil
        self.addressDetail = nil
        self.lat = nil
        self.lon = nil
        self.areaId = nil
        
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case addressId
        case addressDetail
        case eventName
        case start
        case note
        case customRequestServiceRequests
        case venue
    }
    
    public struct ServiceRequest: Encodable {
        public let categoryTypeId: Int
        public let quantity: Int
        public let price: Double
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
