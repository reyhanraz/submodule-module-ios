//
//  CheckAvailabilityCloudService.swift
//  Booking
//
//  Created by Fandy Gotama on 23/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct CheckAvailabilityCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = CheckAvailabilityRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<BookingApi>
    
    public init(service: MoyaProvider<BookingApi> = MoyaProvider<BookingApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: CheckAvailabilityRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx
            .request(.checkAvailability(request: request))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
