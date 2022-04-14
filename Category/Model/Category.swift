//
//  Category.swift
//  Category
//
//  Created by Fandy Gotama on 18/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB

public final class Category: Codable, Hashable, FetchableRecord, PersistableRecord, CustomStringConvertible, Nameable {
    
    public let id: Int
    public let name: String
    public let icon: URL?
    public let status: ItemStatus
    public let childrens: [Category]?
    public let parent: Category?
    
    enum CodingKeys: String, CodingKey{
        case id
        case name
        case icon = "icon_url"
        case status
        case childrens
        case parent
    }
    
    enum Columns: String, ColumnExpression {
        case id
        case name
        case icon
        case status
        case childrens
        case parent
    }
    
    public init(id: Int, name: String, icon: URL?, status: ItemStatus, childrens: [Category]?, parent: Category?) {
        self.id = id
        self.name = name
        self.icon = icon
        self.status = status
        self.childrens = childrens
        self.parent = parent
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decodedStatus = try container.decode(String.self, forKey: .status)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        status = ItemStatus(string: decodedStatus)
        childrens = try container.decodeIfPresent([Category].self, forKey: .childrens)
        parent = try container.decodeIfPresent(Category.self, forKey: .parent)
        icon = try container.decodeIfPresent(URL.self, forKey: .icon)
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
