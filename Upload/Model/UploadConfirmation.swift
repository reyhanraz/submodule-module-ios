//
//  UploadConfirmation.swift
//  Upload
//
//  Created by Reyhan Rifqi Azzami on 24/05/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper

public struct UploadConfirmation: Codable {
    public let filename, mediaType: String
    public let type: String
    public let uploaded: Bool
    public let typeID: String
    public let url: URL?
    
    public init(fileName: String, mediaType: String, type: String, uploaded: Bool, typeID: String, url: URL?){
        self.filename = fileName
        self.mediaType = mediaType
        self.type = type
        self.uploaded = uploaded
        self.typeID = typeID
        self.url = url
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        filename = try container.decode(String.self, forKey: .filename)
        mediaType = try container.decode(String.self, forKey: .mediaType)
        uploaded = try container.decode(Bool.self, forKey: .uploaded)
        typeID = try container.decode(String.self, forKey: .typeID)
        url = try container.decodeIfPresent(URL.self, forKey: .url)
        type = try container.decode(String.self, forKey: .type)
    }

    enum CodingKeys: String, CodingKey {
        case filename, mediaType, type, uploaded
        case typeID = "typeId"
        case url
    }
}
