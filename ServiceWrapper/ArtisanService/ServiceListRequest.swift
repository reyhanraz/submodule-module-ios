//
//  ServiceListRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 28/06/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation
import Platform

public class ServiceListRequest: NewListRequestType, Codable{
    
    public var id: String?
    public var timestamp: TimeInterval? = nil
    public var statuses: [ItemStatus] = [.active]
    public var page: Int = 0
    public var limit: Int = 30
    public var forceReload: Bool = false
    public var ignorePaging: Bool = false
    public var keyword: String? = nil
    public var orderBy: OrderBy? = nil
    public var orderDirection: OrderDirection? = nil
    public let artisan: String?
    public let category: Int?
    
    public init(statuses: [ItemStatus] = [.active], id: String? = nil, page: Int = 0, limit: Int = PlatformConfig.defaultLimit, forceReload: Bool = false, ignorePaging: Bool = false, artisan: String?, category: Int?) {
        self.page = page
        self.statuses = statuses
        self.limit = limit
        self.forceReload = forceReload
        self.id = id
        self.artisan = artisan
        self.category = category
    }
    
    public enum OrderBy: String, Codable {
        case id
    }
    
    public enum OrderDirection: String, Codable {
        case asc
        case desc
    }
}
