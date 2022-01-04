//
//  UpdateAddressCloudService.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import Platform

public struct UpdateAddressCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = AddressRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<AddressApi>
    
    public init(service: MoyaProvider<AddressApi> = MoyaProvider<AddressApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: AddressRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Single<Response>
        
        if let id = request.id {
            response = _service.rx.request(.update(id: id, request: request))
        } else {
            response = _service.rx.request(.insert(request: request))
        }
        
        return response
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
