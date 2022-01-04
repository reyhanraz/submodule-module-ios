//
//  CustomizeRequestDetail.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 03/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct CustomizeRequestDetail: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let customizeRequest: CustomizeRequest
        
        enum CodingKeys: String, CodingKey {
            case customizeRequest = "booking"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case data
        case errors
    }
}
