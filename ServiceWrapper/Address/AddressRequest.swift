//
//  AddressRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 04/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Platform

public struct AddressRequest: Encodable, Editable {
    public let id: Int?
    public let name: String
    public let address: String
    public let notes: String
    public let latitude: Double?
    public let longitude: Double?
    
    public init(addressID: Int?, name: String, notes: String, lat: Double?, lon: Double?, address: String){
        self.name = name
        self.notes = notes
        self.address = address
        self.latitude = lat
        self.longitude = lon

        id = addressID
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case address
        case notes
        case latitude
        case longitude
    }
}
