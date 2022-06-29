//
//  PostServiceRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 09/06/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation
import Platform
public struct PostServiceRequest: Codable{
    public let id: String?
    public let title: String
    public let description: String
    public var status: String
    public let category: Int
    public let duration: Int
    public let original_price: Double
    public let promo_price: Double?

    
    public init(id: String? = nil, title: String, description: String, status: ItemStatus = .active, category: Int, duration: Int, original_price: Double, promo_price: Double?){
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.status = status.stringValue
        self.duration = duration
        self.original_price = original_price
        self.promo_price = promo_price
    }
    
    enum CodingKey: String{
        case id
        case title
        case description
        case category
        case status
        case duration
        case original_price
        case promo_price = "price"
    }
}
