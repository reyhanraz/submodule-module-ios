//
//  ArtisanFilter.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Platform

public class ArtisanFilter: ListRequestType, CustomStringConvertible {
    public enum ListType {
        case favorite
        case nearby
        case search
        case `default`
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
    public var id: Int?
    public var latitude: Double?
    public var longitude: Double?
    public var isEditorChoice: Bool?

    public init(statuses: [ItemStatus] = [.active], listType: ListType = .default, id: Int? = nil, page: Int = 0, limit: Int = PlatformConfig.defaultLimit, forceReload: Bool = false, ignorePaging: Bool = false, ratings: [Int]? = nil, locations: [FilterInfo]? = nil, categories: [FilterInfo]? = nil, categoryTypes: [FilterInfo]? = nil, priceMin: Double? = nil, priceMax: Double? = nil, latitude: Double? = nil, longitude: Double? = nil, isEditorChoice: Bool? = nil) {
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
        self.isEditorChoice = isEditorChoice
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
