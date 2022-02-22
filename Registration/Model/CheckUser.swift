//
//  CheckUser.swift
//  Registration
//
//  Created by Reyhan Rifqi Azzami on 22/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//


public struct CheckUser: Codable{
    public let data: Data
    
    public struct Data: Codable{
        public let id: String
        public let created_at: String
        public let updated_at: String
        public let email: String
        public let phone_number: String
    }
}


