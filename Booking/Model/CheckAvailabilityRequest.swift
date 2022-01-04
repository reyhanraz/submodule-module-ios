//
//  CheckAvailabilityRequest.swift
//  Booking
//
//  Created by Fandy Gotama on 23/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

public struct CheckAvailabilityRequest: Encodable {
    public let artisanId: Int
    public let timeStart: String
    public let serviceRequests: [ServiceRequest]?
    public let customRequestServiceRequests: [CustomRequestServiceRequest]?
    
    public struct ServiceRequest: Encodable {
        public let serviceId: Int
        public let quantity: Int
    }
    
    public struct CustomRequestServiceRequest: Encodable {
        public let categoryTypeId: Int
        public let quantity: Int
    }
}
