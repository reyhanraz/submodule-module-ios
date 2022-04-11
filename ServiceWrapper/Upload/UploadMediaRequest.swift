//
//  UploadMediaRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Common

public struct UploadMediaRequest: Encodable {
    public enum UploadType: String, Encodable {
        case gallery = "Image"
        case avatar = "Avatar"
        case service = "ServiceCover"
        case identity = "IdentityCard"
        case `default`
    }
    
    public let url: URL
    public let fileName: String
    public let mimeType: String
    public let uploadType: UploadType
    public let id: Int?
    
    public init(id: Int? = nil, url: URL, uploadType: UploadType) {
        self.id = id
        self.url = url
        
        self.fileName = url.lastPathComponent
        self.mimeType = url.mimeType
        self.uploadType = uploadType
    }
}
