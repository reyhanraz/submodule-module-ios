//
//  LocationViewModel.swift
//  GoogleLocation
//
//  Created by Reyhan Rifqi Azzami on 30/09/21.
//  Copyright © 2021 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import GooglePlaces

open class LocationViewModel{
    public let outputLocation : PublishSubject<Location> = PublishSubject()
    public let searchLocationResult : PublishSubject<[Location]> = PublishSubject()
    
    public let placesClient = GMSPlacesClient.shared()

    public let serviceManager: LocationGeocodeServiceProtocol
    
    public init(serviceManager: LocationGeocodeServiceProtocol = LocationGeocodeServiceManager.shared){
        self.serviceManager = serviceManager
    }
    
    public func update(lat: Double, long: Double){
        serviceManager.getAdressByCoordinate(latitude: lat, longitude: long) { [weak self] result in
            switch result{
            case .success(let location):
                self?.outputLocation.onNext(location)
            case .failure(_):
                break
            }
        }
    }
    
    public func fetchPlaces(query: String){
        let filter = GMSAutocompleteFilter()
        filter.countries = ["ID"]
        
        var temp = [Location]()

        placesClient.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) {[weak self] predictions, error in
            guard error == nil else {
                return
            }
            guard let predictions = predictions else {
                return
            }
            for i in 0..<predictions.count{
                let place = predictions[i]
                temp.append(Location(placeID: place.placeID,
                                     placeName: place.attributedPrimaryText.string,
                                     placeAddress: place.attributedSecondaryText?.string ?? ""))
            }
            self?.searchLocationResult.onNext(temp)
        }
    }
    
    public func getCoordinate(by placeID: String, completion: @escaping(Result<CLLocationCoordinate2D, LocationError>) -> Void){
        let fields = GMSPlaceField.coordinate
        placesClient.fetchPlace(fromPlaceID: placeID, placeFields: fields, sessionToken: nil) {place, error in
            guard error == nil else {
                completion(.failure(.InvalidInput))
                return
            }
            guard let place = place else {
                completion(.failure(.NoResult))
                return
            }
            
            completion(.success(place.coordinate))
        }
    }
}
