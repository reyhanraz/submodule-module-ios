//
//  ChangePasswordRequest.swift
//  ChangePassword
//
//  Created by Fandy Gotama on 21/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

public struct ChangePasswordRequest: Encodable {
    let password: String
    let newPassword: String
}
