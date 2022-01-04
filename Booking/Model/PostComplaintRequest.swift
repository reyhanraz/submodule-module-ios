//
//  PostComplaintRequest.swift
//  Booking
//
//  Created by Fandy Gotama on 11/01/21.
//  Copyright © 2021 Adrena Teknologi Indonesia. All rights reserved.
//

public struct PostComplaintRequest: Encodable {
    public let bookingId: Int
    public let complaint: String
}
