//
//  BookingDetails.swift
//  Booking
//
//  Created by Reyhan Rifqi Azzami on 18/07/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import Foundation
import Platform
public struct BookingDetails: NewResponseType, Codable {
    
    public let data: BookingDetails.Details
    public var metadata: Metadata?
    
    public init(data: BookingDetails.Details, metadata: Metadata?){
        self.data = data
        self.metadata = metadata
    }
    
     
    public struct Details: Codable {
        public let id: String
        public let createdAt: Date?
        public let updatedAt: Date?
        public let bookingCode: String
        public let bookingCreatedDate: Date?
        public let bookingUpdatedDate: Date?
        public let booking: Booking
        public let platformFee: Decimal
        public let subTotal: Decimal
        public let grandTotal: Decimal

        enum CodingKeys: String, CodingKey {
            case id
            case createdAt = "created_at"
            case updatedAt = "updated_at"
            case bookingCode = "booking_code"
            case bookingCreatedDate = "booking_created_date"
            case bookingUpdatedDate = "booking_updated_date"
            case booking
            case platformFee = "platform_fee"
            case subTotal = "sub_total"
            case grandTotal = "grand_total"
        }
        
        public init(id: String, createdAt: Date, updatedAt: Date, bookingCode: String, bookingCreatedDate: Date, bookingUpdatedDate: Date, booking: Booking, platformFee: Decimal, subTotal: Decimal, grandTotal: Decimal){
            self.id = id
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.bookingCode = bookingCode
            self.bookingCreatedDate = bookingCreatedDate
            self.bookingUpdatedDate = bookingUpdatedDate
            self.booking = booking
            self.platformFee = platformFee
            self.subTotal = subTotal
            self.grandTotal = grandTotal
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
                        
            id = try container.decode(String.self, forKey: .id)
            createdAt = try container.decode(String.self, forKey: .createdAt).toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            updatedAt = try container.decode(String.self, forKey: .updatedAt).toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            bookingCode = try container.decode(String.self, forKey: .bookingCode)
            bookingCreatedDate = try container.decode(String.self, forKey: .bookingCreatedDate).toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            bookingUpdatedDate = try container.decode(String.self, forKey: .bookingUpdatedDate).toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ")
            booking = try container.decode(Booking.self, forKey: .booking)
            platformFee = try container.decode(Decimal.self, forKey: .platformFee)
            subTotal = try container.decode(Decimal.self, forKey: .subTotal)
            grandTotal = try container.decode(Decimal.self, forKey: .subTotal)
        }
    }
}
