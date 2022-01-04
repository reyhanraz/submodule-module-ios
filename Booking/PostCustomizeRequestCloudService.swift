//
//  PostCustomizeRequestCloudService.swift
//  Booking
//
//  Created by Fandy Gotama on 15/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct PostCustomizedRequestCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = PostCustomRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<CustomizeRequestApi>
    
    public init(service: MoyaProvider<CustomizeRequestApi> = MoyaProvider<CustomizeRequestApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: PostCustomRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else {
            return .just(.error(ServiceError.invalidRequest))
        }
        
        
        let response: Single<Response>
        
        if request.id != nil {
            response = _service.rx.request(.updateCustomizedRequest(request: request))
        } else {
            response = _service.rx.request(.createCustomizedRequest(request: request))
        }
        
        return response
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
