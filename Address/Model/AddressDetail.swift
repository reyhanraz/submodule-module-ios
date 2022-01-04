//
//  AddressDetail.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct AddressDetail: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let address: Address
        
        enum CodingKeys: String, CodingKey {
            case address
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case data
        case errors
    }
}

