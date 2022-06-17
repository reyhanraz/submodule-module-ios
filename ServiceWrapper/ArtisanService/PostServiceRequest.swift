//
//  PostServiceRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 09/06/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation
public struct PostServiceRequest{
    public let title: String
    public let description: String
    public let category: Int
    public let duration: Int
    public let original_price: Double
    public let promo_price: Double?

    
    public init(title: String, description: String, category: Int, duration: Int, original_price: Double, promo_price: Double?){
        self.title = title
        self.description = description
        self.category = category
        self.duration = duration
        self.original_price = original_price
        self.promo_price = promo_price
    }
}
