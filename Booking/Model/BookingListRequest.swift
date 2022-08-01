//
//  BookingRequest.swift
//  Booking
//
//  Created by Fandy Gotama on 30/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Platform

public class BookingListRequest: NewListRequestType {
    
    public var id: String?
    public var timestamp: TimeInterval? = nil
    public var statuses: [ItemStatus] = [.active]
    public var page: Int = 0
    public var limit: Int = 30
    public var forceReload: Bool = false
    public var ignorePaging: Bool = false
    public var keyword: String? = nil
    public var bookingStatuses: [Booking.Status]?
    public var artisanId: Int?
    public var bookingType: BookingType?
    public var bidPrice: Double?

    public enum BookingType {
        case booking
        case customizeRequest
    }
    
    public init(statuses: [Booking.Status]? = nil, bookingType: BookingType? = nil, id: String? = nil, artisanId: Int? = nil, page: Int = 0, limit: Int = PlatformConfig.defaultLimit, forceReload: Bool = false, ignorePaging: Bool = false, bidPrice: Double? = nil) {
        self.page = page
        self.bookingStatuses = statuses
        self.limit = limit
        self.forceReload = forceReload
        self.id = id
        self.artisanId = artisanId
        self.bookingType = bookingType
        self.bidPrice = bidPrice
    }
}

extension BookingListRequest {
    
    public var bookingStatusDescriptions: String? {
        return bookingStatuses?.map { Booking.bookingStatusDescription(status: $0) }.joined(separator: ", ")
    }
}
