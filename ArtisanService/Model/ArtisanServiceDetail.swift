//
//  ArtisanServiceDetail.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 24/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct ArtisanServiceDetail: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let service: ArtisanService
        
        enum CodingKeys: String, CodingKey {
            case service = "artisanService"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case data
        case errors
    }
}

