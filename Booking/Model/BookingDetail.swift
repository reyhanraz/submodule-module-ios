//
//  BookingDetail.swift
//  Booking
//
//  Created by Fandy Gotama on 30/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import Payment

public struct BookingDetail: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        //TODO: Delete Old Booking
        public let booking: Booking?
        public let paymentSummary: PaymentSummary?
        
        enum CodingKeys: String, CodingKey {
            case booking
            case paymentSummary
        }
    }
}
