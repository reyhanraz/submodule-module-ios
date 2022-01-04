//
//  ArtisanDetail.swift
//  Artisan
//
//  Created by Fandy Gotama on 16/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct ArtisanDetail: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let user: Artisan
        
        enum CodingKeys: String, CodingKey {
            case user
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case data
        case errors
    }
}

