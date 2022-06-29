//
//  ArtisanService.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 24/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB
import CommonUI

public class ArtisanService: Codable, Pageable, FetchableRecord, PersistableRecord {
    public let id: String
    public let title: String
    public let description: String
    public let status: ItemStatus
    public let duration: Int
    public let price: Decimal
    public let originalPrice: Decimal
    public let category: Category
    public let images: [Media]?
    public let artisan: String
    public let timeStamp: TimeInterval
    public var paging: Paging?
    
    public init(id: String, title: String, description: String, status: ItemStatus, duration: Int, price: Decimal, originalPrice: Decimal, category: ArtisanService.Category, images: [Media], artisan: String, timeStamp: TimeInterval, paging: Paging?) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.duration = duration
        self.price = price
        self.originalPrice = originalPrice
        self.category = category
        self.images = images
        self.artisan = artisan
        self.timeStamp = timeStamp
        self.paging = paging
    }
    
    public class Category: Codable{
        public let id: Int
        public let name: String
        public let status: String
        public let parent: Category?
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        
        let _status = try container.decode(String.self, forKey: .status)
        self.status = ItemStatus.init(string: _status)
        
        self.duration = try container.decode(Int.self, forKey: .duration)
        self.price = try container.decode(Decimal.self, forKey: .price)
        self.originalPrice = try container.decode(Decimal.self, forKey: .originalPrice)
        self.category = try container.decode(Category.self, forKey: .category)
        
        let _images = try container.decodeIfPresent([URL].self, forKey: .images)
        self.images = _images?.map({Media(url: $0, servingURL: nil) })
        
        self.artisan = try container.decode(String.self, forKey: .artisan)
        self.timeStamp = Date().timeIntervalSince1970
        self.paging = try container.decodeIfPresent(Paging.self, forKey: .paging)

    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case status
        case duration
        case price
        case originalPrice
        case category
        case images
        case artisan
        case paging
        case timeStamp
    }
    
    
    enum Columns: String, ColumnExpression {
        case id
        case title
        case description
        case status
        case duration
        case price
        case originalPrice
        case category
        case images
        case artisan
        case paging
        case topParentId
    }
}

extension ArtisanService {
    public var categoryData: Data?{
        let encoder = JSONEncoder()
        return try? encoder.encode(category)
    }
    
    public var imagesData: Data?{
        let encoder = JSONEncoder()
        return try? encoder.encode(images)
    }
    
    public var topParent: Category?{
        return category.parent?.parent
    }
}
