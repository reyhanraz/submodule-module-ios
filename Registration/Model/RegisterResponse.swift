//
//  RegisterResponse.swift
//  Registration
//
//  Created by Reyhan Rifqi Azzami on 23/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

public struct RegisterResponse: Codable{
    public let email: String
    public let id: String
    public let phone_number: String
}
