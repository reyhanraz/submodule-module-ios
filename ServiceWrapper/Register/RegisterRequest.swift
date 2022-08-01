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
    public var phone: String?
    public let gender: NewProfile.Gender
    public var challenge_token: String?
    public let type: String
    
    public let instagram: String?
    public let username: String?
    public let birthdate: String?
    public let categories: [Int]?
    
    public init(name: String, email: String, password: String, phone: String? = nil, gender: NewProfile.Gender, challenge_token: String? = nil){
        self.name = name
        self.email = email
        self.password = password
        self.phone = phone
        self.gender = gender
        self.challenge_token = challenge_token
        self.type = "customer"
        
        self.instagram = nil
        self.username = nil
        self.birthdate = nil
        self.categories = nil
    }
    
    public init(name: String, email: String, password: String, phone: String? = nil, gender: NewProfile.Gender, challenge_token: String? = nil, instagram: String, username: String, dob: String, categories: [Int]){
        self.name = name
        self.email = email
        self.password = password
        self.phone = phone
        self.gender = gender
        self.challenge_token = challenge_token
        self.type = "artisan"
        
        self.instagram = instagram
        self.username = username
        self.birthdate = dob
        self.categories = categories
    }
}
