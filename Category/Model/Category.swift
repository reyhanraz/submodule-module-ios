//
//  Category.swift
//  Category
//
//  Created by Fandy Gotama on 18/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB

public struct Category: Codable, Hashable, FetchableRecord, PersistableRecord, CustomStringConvertible, Nameable {
    
    public let id: Int
    public let name: String
    public let icon: URL
    public let order: Int
    public let status: ItemStatus
    public let timestamp: TimeInterval?
    
    enum Columns: String, ColumnExpression {
        case id
        case name
        case icon
        case order
        case status
        case timestamp
    }
    
    public init(id: Int, name: String, icon: URL, order: Int, status: ItemStatus, timestamp: TimeInterval?) {
        self.id = id
        self.name = name
        self.icon = icon
        self.order = order
        self.status = status
        self.timestamp = timestamp
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decodedStatus = try container.decode(String.self, forKey: .status)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        order = try container.decode(Int.self, forKey: .order)
        status = ItemStatus(string: decodedStatus)
        icon = try container.decode(URL.self, forKey: .icon)
        
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Category: TableRecord {
    static let categoryTypes = hasMany(CategoryType.self)
}
