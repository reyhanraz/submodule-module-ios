//
//  RegisterRequest.swift
//  Registration
//
//  Created by Fandy Gotama on 12/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct RegisterRequest: Encodable {
    public let name: String
    public let email: String
    public let password: String
    public let phone: String
    public let gender: User.Gender
}
