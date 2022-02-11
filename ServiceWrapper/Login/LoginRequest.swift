//
//  LoginRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 10/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation

public struct LoginRequest: Encodable {
    public enum Grant_Type: String{
        case password
        case google
        case facebook
        case apple
        case refreshToken = "refresh_token"
        case artisanPassword = "artisan_password"
        case artisanGoogle = "google_artisan"
        case artisanFacebook = "facebook_artisan"
        
    }
    
    let identifier: String?
    let password: String?
    let grant_type: String
    
    public init(identifier: String?, password: String? = nil, grantType: LoginRequest.Grant_Type){
        self.identifier = identifier
        self.password = password
        self.grant_type = grantType.rawValue
    }
}

public struct Token: Codable {
    public let access_token: String
    public let expires_in: Double
    public let refresh_token: String
    public let token_type: String
}
