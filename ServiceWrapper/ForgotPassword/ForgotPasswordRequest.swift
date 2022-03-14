//
//  ForgotPasswordRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 04/03/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

public struct ForgotPasswordRequest: Codable{
    let email: String
    let type: String
    
    public init(email: String, type: String){
        self.email = email
        self.type = type
    }
}
