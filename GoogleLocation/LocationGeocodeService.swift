//
//  LocationGeocodeService.swift
//  GoogleLocation
//
//  Created by Reyhan Rifqi Azzami on 29/09/21.
//  Copyright © 2021 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation
import GoogleMaps
public protocol LocationGeocodeServiceProtocol{
    func getAdressByCoordinate(latitude: Double, longitude: Double, completion: @escaping(Result<Location, LocationError>) -> Void)

}

public class LocationGeocodeServiceManager: LocationGeocodeServiceProtocol{
    public let geoCode: GMSGeocoder?
    public static let shared = LocationGeocodeServiceManager(geoCode: GMSGeocoder())
    
    
    init(geoCode: GMSGeocoder = GMSGeocoder()) {
        self.geoCode = geoCode
    }
    
    public func getAdressByCoordinate(latitude: Double, longitude: Double, completion: @escaping(Result<Location, LocationError>) -> Void){
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        geoCode?.reverseGeocodeCoordinate(coordinate, completionHandler: { ressponse, error in
            guard error == nil else{
                completion(.failure(LocationError.InvalidInput))
                return
            }
            guard let data = ressponse?.firstResult() else{
                completion(.failure(LocationError.NoResult))
                return
            }
            let name = data.thoroughfare ?? data.locality ?? data.subLocality ?? data.administrativeArea ?? ""
            let address = data.lines?.first ?? data.administrativeArea ?? ""
            completion(.success(Location(placeName: name, placeAddress: address, latitude: data.coordinate.latitude, longitude: data.coordinate.longitude)))
        })
    }
}
