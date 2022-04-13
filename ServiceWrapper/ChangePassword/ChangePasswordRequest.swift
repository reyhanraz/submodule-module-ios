//
//  ChangePasswordRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

public struct ChangePasswordRequest: Encodable {
    let password: String
    let newPassword: String
    
    public init(password: String, newPassword: String){
        self.password = password
        self.newPassword = newPassword
    }
}
