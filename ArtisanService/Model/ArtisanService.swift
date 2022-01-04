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
    public let id: Int
    public let artisanId: Int
    public let title: String
    public let description: String
    public let price: Decimal
    public let status: ItemStatus
    public let cover: Media

    public let serviceTypes: [ServiceType]
    public let tags: [String]?
    
    public var timestamp: TimeInterval?
    public var paging: Paging?

    private let coverServingURL: URL?

    public init(id: Int, artisanId: Int, title: String, description: String, price: Decimal, status: ItemStatus, cover: Media, coverServingURL: URL?, serviceTypes: [ServiceType], tags: [String]?, paging: Paging? = nil, timestamp: TimeInterval? = nil) {
        self.id = id
        self.artisanId = artisanId
        self.title = title
        self.description = description
        self.price = price
        self.status = status
        self.cover = cover
        self.coverServingURL = coverServingURL
        self.serviceTypes = serviceTypes
        self.tags = tags
        self.timestamp = timestamp
        self.paging = paging
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decodedURL = try container.decode(URL.self, forKey: .cover)
        let decodedStatus = try container.decode(String.self, forKey: .status)
        let decodedPrice = try container.decode(String.self, forKey: .price)
        
        id = try container.decode(Int.self, forKey: .id)
        artisanId = try container.decode(Int.self, forKey: .artisanId)
        
        title = try container.decode(String.self, forKey: .title)
        
        description = try container.decode(String.self, forKey: .description)
        
        serviceTypes = try container.decode([ServiceType].self, forKey: .serviceTypes)
        coverServingURL = try container.decodeIfPresent(URL.self, forKey: .coverServingURL)

        cover = Media(url: decodedURL, servingURL: coverServingURL)
        status = ItemStatus(string: decodedStatus)
        price = Decimal(string: decodedPrice) ?? .zero
        
        tags = try container.decodeIfPresent([String].self, forKey: .tags)
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
    }
    
    public struct ServiceTag: Codable, FetchableRecord, PersistableRecord {
        public let serviceCategoryId: Int
        public let tag: String
        
        enum Columns: String, ColumnExpression {
            case tag
        }
    }
    
    public struct ServiceType: Codable, FetchableRecord, PersistableRecord {
        public let id: Int
        public let serviceCategoryId: Int
        public let name: String

        enum Columns: String, ColumnExpression {
            case id
            case serviceCategoryId
            case name
        }
        
        public init(id: Int, serviceCategoryId: Int, name: String) {
            self.id = id
            self.serviceCategoryId = serviceCategoryId
            self.name = name
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            id = try container.decode(Int.self, forKey: .id)
            serviceCategoryId = try container.decode(Int.self, forKey: .serviceCategoryId)
            name = try container.decode(String.self, forKey: .name)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case artisanId
        case title
        case description
        case price
        case status
        case cover = "coverUrl"
        case coverServingURL = "coverServingUrl"
        case serviceTypes = "categoryTypes"
        case tags
        case timestamp
    }
    
    enum Columns: String, ColumnExpression {
        case id
        case artisanId
        case title
        case description
        case price
        case status
        case cover = "coverUrl"
        case coverServingURL = "coverServingUrl"
    }
}

extension ArtisanService: TableRecord {
    static let serviceType = hasMany(ServiceType.self)
    static let tags = hasMany(ServiceTag.self)
}

extension ArtisanService.ServiceType: TableRecord {
    static let artisanService = belongsTo(ArtisanService.self)
}

extension ArtisanService.ServiceTag: TableRecord {
    static let artisanService = belongsTo(ArtisanService.self)
}

extension ArtisanService {
    public var types: String {
        return serviceTypes.map { $0.name }.joined(separator: ", ")
    }

    public var categoryId: Int? {
        return serviceTypes.map { $0.serviceCategoryId }.first
    }
    
    public var serviceTypeId: Int? {
        return serviceTypes.map { $0.id }.first
    }
    
    public var typesAndPriceAndDescription: String {
        let formatter = CurrencyFormatter()
        
        if let price = formatter.format(price: price) {
            return "\(types), \(price)\n\(description)"
        } else {
            return "\(types)\n\(description)"
        }
    }
}
