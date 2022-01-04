//
//  Availability.swift
//  Booking
//
//  Created by Fandy Gotama on 23/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct Availability: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let available: Bool
    }
}
