//
//  CustomizeListRequest.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 03/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Platform

public class CustomizeListRequest: ListRequestType, Editable {
    public var id: Int?
    public var timestamp: TimeInterval? = nil
    public var statuses: [ItemStatus] = [.active]
    public var page: Int = 0
    public var limit: Int = 30
    public var forceReload: Bool = false
    public var ignorePaging: Bool = false
    public var keyword: String? = nil
    public var customizeRequestStatuses: [CustomizeRequest.Status]?
    
    public init(statuses: [CustomizeRequest.Status]? = nil, id: Int? = nil, page: Int = 0, limit: Int = PlatformConfig.defaultLimit, forceReload: Bool = false, ignorePaging: Bool = false) {
        self.page = page
        self.customizeRequestStatuses = statuses
        self.limit = limit
        self.forceReload = forceReload
        self.id = id
    }
}
