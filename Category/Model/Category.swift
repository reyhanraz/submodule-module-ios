//
//  Category.swift
//  Category
//
//  Created by Fandy Gotama on 18/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB

public class Category: Codable, Hashable, FetchableRecord, PersistableRecord, CustomStringConvertible, Nameable {
    
    public let id: Int
    public let name: String
    public let icon_url: URL?
    public let status: ItemStatus
    public let childrens: [Category]?
    
    enum CodingKeys: String, CodingKey{
        case id
        case name
        case icon_url
        case status
        case childrens
    }
    
    public enum Columns: String, ColumnExpression {
        case id
        case name
        case icon_url
        case status
        case childrens
    }
    
    public init(id: Int, name: String, icon_url: URL?, status: ItemStatus, childrens: [Category]?) {
        self.id = id
        self.name = name
        self.icon_url = icon_url
        self.status = status
        self.childrens = childrens
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        do {
            status = ItemStatus(string: try container.decode(String.self, forKey: .status))
        } catch  {
            status = ItemStatus(int: try container.decode(Int.self, forKey: .status))
        }
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        childrens = try container.decodeIfPresent([Category].self, forKey: .childrens)
        icon_url = try container.decodeIfPresent(URL.self, forKey: .icon_url)
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Category, rhs: Category) -> Bool {
        true
    }
}

extension Category: TableRecord {
    static let categoryTypes = hasMany(CategoryType.self)
}

extension Category{
    var childrenData: Data?{
        let encoder = JSONEncoder()
        return try? encoder.encode(childrens)
    }
}
