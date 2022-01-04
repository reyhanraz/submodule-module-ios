//
//  AddressRequest.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct AddressRequest: Encodable, Editable {
    public let id: Int?
    public let name: String?
    public let detail: String?
    public let areaId: Int?
    public let rawAddress: [String: String]?
    public let location: Location?
    public let note: String?
    
    //MARK: - INIT For Insert Address
    public init(addressID: Int?, name: String?, note: String?, lat: Double?, lon: Double?, address: String?, areaId: Int? = nil, rawAddress: [String: String]? = nil){
        self.name = name
        self.note = note
        self.rawAddress = rawAddress
        self.location = Location(latitude: lat,
                                 longitude: lon,
                                 address: address)

        id = addressID
        detail = address
        self.areaId = areaId
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case detail
        case areaId
        case location
        case rawAddress
        case note
    }
    
    public struct Location: Encodable{
        public let latitude: Double?
        public let longitude: Double?
        public let address: String?
        
        enum CodingKeys: String, CodingKey{
            case latitude
            case longitude
            case address
        }

    }
}

