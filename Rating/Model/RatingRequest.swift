//
//  RatingRequest.swift
//  Rating
//
//  Created by Fandy Gotama on 01/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
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
