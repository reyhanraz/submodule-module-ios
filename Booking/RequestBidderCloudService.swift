//
//  RequestBidderCloudService.swift
//  Booking
//
//  Created by Fandy Gotama on 22/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct RequestBidderCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = Int
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<CustomizeRequestApi>
    
    public init(service: MoyaProvider<CustomizeRequestApi> = MoyaProvider<CustomizeRequestApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: Int?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx.request(.getBidder(id: request))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
