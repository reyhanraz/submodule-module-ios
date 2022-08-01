//
//  ProfileRequest.swift
//  Profile
//
//  Created by Fandy Gotama on 20/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct ProfileRequest: Encodable {
    let id: String
    let name: String
    let phone: String
    let dob: String?
    let gender: NewProfile.Gender
    
    public init(id: String, name: String, phone: String, dob: String?, gender: NewProfile.Gender) {
        self.id = id
        self.name = name
        self.phone = phone
        self.dob = dob
        self.gender = gender
    }
}
