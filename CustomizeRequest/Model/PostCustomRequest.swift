//
//  PostCustomRequest.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 03/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

public struct PostCustomRequest: Encodable {
    public let addressId: Int?
    public let addressName: String?
    public let addressDetail: String?
    public let areaId: Int?
    public let eventName: String
    public let start: String
    public let note: String?
    public let customRequestServiceRequests: [ServiceRequest]
    
    public init(addressId: Int?, addressName: String?, addressDetail: String?, areaId: Int?, eventName: String, start: String, note: String?, bookingServiceRequests: [ServiceRequest]) {
        self.addressId = addressId
        self.addressName = addressName
        self.addressDetail = addressDetail
        self.areaId = areaId
        self.eventName = eventName
        self.start = start
        self.note = note
        self.customRequestServiceRequests = bookingServiceRequests
    }
    
    enum CodingKeys: String, CodingKey {
        case addressId
        case addressDetail
        case eventName
        case start
        case note
        case customRequestServiceRequests
    }
    
    public struct ServiceRequest: Encodable {
        public let categoryTypeId: Int
        public let quantity: Int
        public let price: Double
    }
}
