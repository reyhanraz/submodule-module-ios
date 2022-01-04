//
//  ArtisanServiceRequest.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 24/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct ArtisanServiceRequest: Encodable, Editable {
    public let id: Int?
    public let title: String
    public let categoryTypeIds: [Int]
    public let description: String?
    public let price: Double
    public let cover: Cover?
    
    public struct Cover: Encodable {
        public let name: String
        
        enum CodingKeys: String, CodingKey {
            case name = "temporaryObjectName"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case categoryTypeIds
        case price
        case description
        case cover = "preUploadCover"
    }
}
