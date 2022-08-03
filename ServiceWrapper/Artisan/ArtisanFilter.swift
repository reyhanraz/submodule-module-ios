//
//  ArtisanFilter.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Platform

public class ArtisanFilter: NewListRequestType, CustomStringConvertible {
    public enum ListType {
        case favorite
        case nearby
        case search
        case trending
        case editorChoice
    }
    
    public enum Order: String{
        case ASC
        case DESC
    }
    
    public enum OrderBy: String{
        case rating
    }

    public var timestamp: TimeInterval?
    public var statuses: [ItemStatus]
    public var listType: ListType
    public var page: Int
    public var limit: Int
    public var forceReload: Bool
    public var ignorePaging: Bool
    public var keyword: String?
    public var ratings: [Int]?
    public var locations: [FilterInfo]?
    public var categories: [FilterInfo]?
    public var categoryTypes: [FilterInfo]?
    public var priceMin: Double?
    public var priceMax: Double?
    public var id: String?
    public var latitude: Double?
    public var longitude: Double?
    public var orderBy: String?
    public var order: String?

    public init(statuses: [ItemStatus] = [.active], listType: ListType = .trending, id: String? = nil, page: Int = 0, limit: Int = PlatformConfig.defaultLimit, forceReload: Bool = false, ignorePaging: Bool = false, ratings: [Int]? = nil, locations: [FilterInfo]? = nil, categories: [FilterInfo]? = nil, categoryTypes: [FilterInfo]? = nil, priceMin: Double? = nil, priceMax: Double? = nil, latitude: Double? = nil, longitude: Double? = nil, orderBy: OrderBy = .rating, order: Order = .ASC) {
        self.id = id
        self.page = page
        self.statuses = statuses
        self.limit = limit
        self.forceReload = forceReload
        self.ignorePaging = ignorePaging
        self.ratings = ratings
        self.locations = locations
        self.categories = categories
        self.categoryTypes = categoryTypes
        self.priceMin = priceMin
        self.priceMax = priceMax
        self.latitude = latitude
        self.longitude = longitude
        self.listType = listType
        self.orderBy = orderBy.rawValue
        self.order = order.rawValue
    }
}

extension ArtisanFilter {
    
    public func reset() {
        ratings = nil
        locations = nil
        categories = nil
        categoryTypes = nil
        priceMin = nil
        priceMax = nil
    }
}
