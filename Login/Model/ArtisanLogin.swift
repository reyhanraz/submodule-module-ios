//
//  ArtisanLogin.swift
//  Login
//
//  Created by Fandy Gotama on 27/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct ArtisanLogin: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let user: Artisan?
        public let token: String?
        
        enum CodingKeys: String, CodingKey {
            case user
            case token
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case data
        case errors = "error"
    }
}
