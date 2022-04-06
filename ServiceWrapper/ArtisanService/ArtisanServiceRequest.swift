//
//  ArtisanServiceRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
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
        
        public init (name: String){
            self.name = name
        }
    }
    
    public init(id: Int?, title: String, categoryTypeIds: [Int], description: String?, price: Double, cover: ArtisanServiceRequest.Cover?){
        self.id = id
        self.title = title
        self.categoryTypeIds = categoryTypeIds
        self.description = description
        self.price = price
        self.cover = cover
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
