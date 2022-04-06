//
//  RatingRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

public struct RatingRequest: Encodable {
    public let bookingId: Int
    public let rating: Int
    public let comment: String?
    
    public init(bookingId: Int, rating: Int, comment: String?) {
        self.bookingId = bookingId
        self.rating = rating
        self.comment = comment
    }
}
