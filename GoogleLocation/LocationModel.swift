//
//  LocationModel.swift
//  GoogleLocation
//
//  Created by Reyhan Rifqi Azzami on 29/09/21.
//  Copyright © 2021 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation

public struct Location: Equatable{
    public init(placeID: String? = nil, placeName: String, placeAddress: String, latitude: Double? = nil, longitude: Double? = nil){
        self.placeName = placeName
        self.placeAddress = placeAddress
        self.latitude = latitude
        self.longitude = longitude
        self.placeID = placeID
    }
    public let placeID: String?
    public let placeName: String
    public let placeAddress: String
    public let latitude: Double?
    public let longitude: Double?
}

public enum LocationError: Error{
    case NoConnection
    case InvalidInput
    case NoResult
}
extension LocationError: LocalizedError{
    public var errorDescription: String?{
        switch self {
        case .NoConnection:
            return "No Internet Connection"
        case .InvalidInput:
            return "Invalid Coordinate"
        case .NoResult:
            return "No Result"
        }
    }
}
