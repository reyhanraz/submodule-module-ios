//
//  RegisterRequest.swift
//  Registration
//
//  Created by Fandy Gotama on 12/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct RegisterRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let phone: String
    let gender: User.Gender
}
