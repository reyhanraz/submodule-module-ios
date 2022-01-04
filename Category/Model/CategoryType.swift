//
//  CategoryType.swift
//  Category
//
//  Created by Fandy Gotama on 22/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB

public struct CategoryType: Codable, Hashable, FetchableRecord, PersistableRecord, CustomStringConvertible, Nameable {
    
    public let id: Int
    public let serviceCategoryId: Int
    public let name: String
    public let description: String
    public let status: ItemStatus
    public let timestamp: TimeInterval?
    
    enum Columns: String, ColumnExpression {
        case id
        case serviceCategoryId
        case name
        case description
        case status
        case timestamp
    }
    
    public init(id: Int, serviceCategoryId: Int, name: String, description: String, status: ItemStatus, timestamp: TimeInterval?) {
        self.id = id
        self.serviceCategoryId = serviceCategoryId
        self.name = name
        self.description = description
        self.status = status
        self.timestamp = timestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decodedStatus = try container.decode(String.self, forKey: .status)
        
        id = try container.decode(Int.self, forKey: .id)
        serviceCategoryId = try container.decode(Int.self, forKey: .serviceCategoryId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        status = ItemStatus(string: decodedStatus)
        
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
    }
}

extension CategoryType: TableRecord {
    static let category = belongsTo(Category.self)
}
