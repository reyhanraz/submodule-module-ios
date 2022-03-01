//
//  RegisterRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 22/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Platform

public struct RegisterRequest: Encodable {
    public let name: String
    public let email: String
    public let password: String
    public let phone: String?
    public let gender: User.Gender
    public let challenge_token: String?
    public let type: String
    
    public init(name: String, email: String, password: String, phone: String? = nil, gender: User.Gender, challenge_token: String? = nil, type: String){
        self.name = name
        self.email = email
        self.password = password
        self.phone = phone
        self.gender = gender
        self.challenge_token = challenge_token
        self.type = type
    }
}
