//
//  ArtisanProfileRequest.swift
//  Profile
//
//  Created by Fandy Gotama on 27/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct ArtisanProfileRequest: Encodable {
    let id: Int
    let name: String
    let phone: String
    let dob: String?
    let instagram: String?
    let about: String
    let gender: User.Gender
    
    public init(id: Int, name: String, phone: String, dob: String?, instagram: String?, about: String, gender: User.Gender) {
        self.id = id
        self.name = name
        self.phone = phone
        self.dob = dob
        self.gender = gender
        self.instagram = instagram
        self.about = about
    }
}

