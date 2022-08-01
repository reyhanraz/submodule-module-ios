//
//  CategoryListRequest.swift
//  Category
//
//  Created by Reyhan Rifqi Azzami on 14/07/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import Platform

public class CategoryListRequest: NewListRequestType, Codable{
    
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
    public let categoryID: Int?
    
    public init(statuses: [ItemStatus] = [.active], id: String? = nil, page: Int = 0, limit: Int = PlatformConfig.defaultLimit, forceReload: Bool = false, ignorePaging: Bool = false, categoryID: Int? = nil) {
        self.page = page
        self.statuses = statuses
        self.limit = limit
        self.forceReload = forceReload
        self.id = id
        self.categoryID = categoryID
    }
    
    public enum OrderBy: String, Codable {
        case id
    }
    
    public enum OrderDirection: String, Codable {
        case asc
        case desc
    }
}
