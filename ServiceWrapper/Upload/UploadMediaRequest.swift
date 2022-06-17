//
//  UploadMediaRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Common

public struct UploadMediaRequest {
    public enum UploadType: String, Codable {
        case gallery = "Image"
        case avatar
        case service = "service-image"
        case identity = "identity-card"
        case selfieWithID = "identity-selfie"
        case `default`
    }
    
    public let url: URL?
    public let data: Data?
    public let uploadType: UploadType
    public let id: String
    
    public init(id: String, url: URL? = nil, data: Data? = nil, uploadType: UploadType) {
        self.id = id
        self.url = url
        self.uploadType = uploadType
        self.data = data
    }
}
