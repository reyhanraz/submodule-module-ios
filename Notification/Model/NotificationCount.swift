//
//  NotificationCount.swift
//  Notification
//
//  Created by Fandy Gotama on 29/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct NotificationCount: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let unread: Int
    }
}
