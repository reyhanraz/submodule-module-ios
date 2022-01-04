//
//  RequestBidders.swift
//  Booking
//
//  Created by Fandy Gotama on 22/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct RequestBidders: Codable, ResponseListType {
    public typealias Data = ListData
    
    public let data: Data?
    public let status: Status.Detail
    public let errors: [DataError]?
    
    public init(data: Data?, status: Status.Detail, errors: [DataError]? = nil) {
        self.data = data
        self.status = status
        self.errors = errors
    }
    
    public struct ListData: DataType, Codable {
        public let list: [Bid]
        public let paging: Paging?
        
        enum CodingKeys: String, CodingKey {
            case list = "bids"
            case paging
        }
    }

    public struct Bid: Codable {
        public let bookingId: Int
        public let price: Decimal
        public let createdAt: Date
        public let artisan: Artisan

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let decodedCreated = try container.decode(String.self, forKey: .createdAt)
            let decodedPrice = try container.decode(String.self, forKey: .price)

            createdAt = decodedCreated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
            bookingId = try container.decode(Int.self, forKey: .bookingId)
            price = Decimal(string: decodedPrice) ?? 0
            artisan = try container.decode(Artisan.self, forKey: .artisan)
        }

        enum CodingKeys: String, CodingKey {
            case bookingId
            case price
            case createdAt
            case artisan
        }
    }
}

