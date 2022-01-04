//
//  Addresses.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct Addresses: Codable, ResponseListType {
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
        public let list: [Address]
        public let paging: Paging?
        
        init(list: [Address], paging: Paging? = nil) {
            self.list = list
            self.paging = paging
        }
        
        enum CodingKeys: String, CodingKey {
            case list = "addresses"
            case paging
        }
    }
}

