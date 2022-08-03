//
//  CalendarRequest.swift
//  Calendar
//
//  Created by Fandy Gotama on 20/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

public struct CalendarRequest {
    public let start: Date?
    public let end: Date?
    public let artisanId: String
    public let forceReload: Bool
    
    public init(start: Date?, end: Date?, artisanId: String, forceReload: Bool = false) {
        self.start = start
        self.end = end
        self.artisanId = artisanId
        self.forceReload = forceReload
    }
}
