//
//  UpdateLocationCloudService.swift
//  Address
//
//  Created by Fandy Gotama on 05/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import Platform
import CoreLocation

public struct UpdateLocationCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = CLLocationCoordinate2D
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<AddressApi>
    
    public init(service: MoyaProvider<AddressApi> = MoyaProvider<AddressApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: CLLocationCoordinate2D?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx.request(.updateLocation(lat: request.latitude, lon: request.longitude))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
