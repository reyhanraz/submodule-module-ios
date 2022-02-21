//
//  ChallengerRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 18/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

public struct ChallengerRequest: Codable{
    public let descriptor: String?
    public let type: String?
    public let user_type: String?
    public var secret: String?
    public let token: String?
    public let number: String?
    public let country_code: String?
    
    public init(descriptor: String?, type: String?, user_type: String?, secret: String? = nil){
        self.descriptor = descriptor
        self.type = type
        self.secret = secret
        self.user_type = user_type
        token = nil
        number = nil
        country_code = nil
    }
}
