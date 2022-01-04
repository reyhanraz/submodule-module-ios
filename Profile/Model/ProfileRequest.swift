//
//  ProfileRequest.swift
//  Profile
//
//  Created by Fandy Gotama on 20/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct ProfileRequest: Encodable {
    let id: Int
    let name: String
    let phone: String
    let dob: String?
    let gender: User.Gender
    
    public init(id: Int, name: String, phone: String, dob: String?, gender: User.Gender) {
        self.id = id
        self.name = name
        self.phone = phone
        self.dob = dob
        self.gender = gender
    }
}
