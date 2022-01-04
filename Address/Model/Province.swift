//
//  Province.swift
//  Address
//
//  Created by Fandy Gotama on 10/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public struct Province: Codable, FetchableRecord, PersistableRecord, Hashable, Nameable {
    public let id: Int
    public let mainDistrictId: Int
    public let name: String
    
    public var timestamp: TimeInterval?
    
    enum Columns: String, ColumnExpression {
        case id
        case mainDistrictId
        case name
    }
}
