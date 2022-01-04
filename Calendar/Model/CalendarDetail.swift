//
//  CalendarDetail.swift
//  Calendar
//
//  Created by Fandy Gotama on 20/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct CalendarDetail: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let calendar: Calendar
        
        enum CodingKeys: String, CodingKey {
            case calendar
        }
    }
}
