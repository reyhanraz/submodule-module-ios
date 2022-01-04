//
//  Location.swift
//  Address
//
//  Created by Fandy Gotama on 29/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB

public struct Location: Codable, FetchableRecord, PersistableRecord {
    public let id: Int
    public let provinceId: Int
    public let provinceName: String
    public let districtId: Int
    public let districtName: String
    public let districtType: String
    public let subDistrictName: String
    public let urbanVillageName: String
    public let postalCode: String
    
    public var timestamp: TimeInterval?
    
    public var villageAndSubDistrict: String {
        return "\(urbanVillageName), \(subDistrictName)"
    }
    
    enum Columns: String, ColumnExpression {
        case id
        case provinceId
        case provinceName
        case districtId
        case districtName
        case districtType
        case subDistrictName
        case urbanVillageName
        case postalCode
    }
}
