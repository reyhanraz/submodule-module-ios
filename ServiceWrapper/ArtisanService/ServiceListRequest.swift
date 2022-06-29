//
//  ServiceListRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 28/06/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation

public struct ServiceListRequest: Codable{
    public let artisan: String?
    public let category: Int?
    
    public init(artisan: String?, category: Int?){
        self.artisan = artisan
        self.category = category
    }
}
