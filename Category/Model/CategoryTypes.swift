//
//  CategoryTypes.swift
//  Category
//
//  Created by Fandy Gotama on 22/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct CategoryTypes: Codable, ResponseListType {
    public typealias Data = ListData
    
    public let data: Data?
    public let status: Status.Detail
    public let errors: [DataError]?
    
    public init(data: Data?, status: Status.Detail, errors: [DataError]? = nil) {
        self.data = data
        self.status = status
        self.errors = errors
    }
    
    public struct ListData: DataType, Codable {
        public let list: [CategoryType]
        public let paging: Paging?
        
        enum CodingKeys: String, CodingKey {
            case list = "categoryTypes"
            case paging
        }
    }
}
