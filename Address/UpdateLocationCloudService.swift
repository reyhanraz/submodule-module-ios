//
//  UpdateLocationCloudService.swift
//  Address
//
//  Created by Fandy Gotama on 05/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import Platform
import CoreLocation

public class UpdateLocationCloudService<CloudResponse: ResponseType>: AddressAPI, ServiceType {
    public typealias R = CLLocationCoordinate2D
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init(){
        super.init()
    }
    
    public func get(request: CLLocationCoordinate2D?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.updateLocation(lat: request.latitude, lon: request.longitude)
                    .retry(3)
                    .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
