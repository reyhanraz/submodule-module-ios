//
//  MetadataRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 27/05/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation

public struct MetadataRequest: Codable {
    public enum RequestType{
        case bio(value: String)
        case id_card(value: String)
    }
    public let name: String
    public let value: String
    public let data_type: String
    public let editCurrentValue: Bool
    
    public init(request: MetadataRequest.RequestType, editCurrentValue: Bool = false){
        switch request{
        case .bio(value: let value):
            self.name = "bio"
            self.value = value
            self.data_type = "string"
        case .id_card(value: let value):
            self.name = "id_card"
            self.value = value
            self.data_type = "number"
        }
        self.editCurrentValue = editCurrentValue
    }
}
