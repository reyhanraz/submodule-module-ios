//
//  MediaSigned.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Platform

public struct MediaSigned: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let signed: Signed
    }
    
    public struct Signed: Codable {
        public let url: URL
        public let temporaryObjectName: String
    }
}
