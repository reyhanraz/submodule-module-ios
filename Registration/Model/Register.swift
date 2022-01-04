//
//  Register.swift
//  Registration
//
//  Created by Fandy Gotama on 12/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//
import Platform

public struct Register: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let user: User
    
        enum CodingKeys: String, CodingKey {
            case user
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case data
        case errors = "error"
    }
}
