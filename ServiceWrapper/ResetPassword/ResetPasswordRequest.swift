//
//  ResetPasswordRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 07/03/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

public struct ResetPasswordRequest: Codable{
    let token: String
    let password: String
    
    public init(token: String, password: String){
        self.token = token
        self.password = password
    }
    
}
