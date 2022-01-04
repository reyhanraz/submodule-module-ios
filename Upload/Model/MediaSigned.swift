//
//  MediaSigned.swift
//  Upload
//
//  Created by Fandy Gotama on 05/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
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
