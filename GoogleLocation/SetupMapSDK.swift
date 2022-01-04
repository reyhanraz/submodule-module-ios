//
//  SetupMapSDK.swift
//  GoogleLocation
//
//  Created by Reyhan Rifqi Azzami on 29/09/21.
//  Copyright © 2021 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation
import GoogleMaps
import GooglePlaces

public struct SetupMapSDK{
    public init(){}
    
    public func provideAPIKey(key: String){
        GMSServices.provideAPIKey(key)
        GMSPlacesClient.provideAPIKey(key)
    }
}
