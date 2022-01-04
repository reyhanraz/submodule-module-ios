//
//  UpdateAddressUseCaseProvider.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import RxSwift
import Domain

public struct UpdateAddressUseCaseProvider<CloudService: ServiceType, Provider: Cache, ServiceRequest: Editable>: UseCase
    where
    CloudService.R == ServiceRequest, CloudService.T == AddressDetail, CloudService.E == Error,
    Provider.R == ServiceRequest, Provider.T == Address {
    
    public typealias R = CloudService.R
    public typealias T = CloudService.T
    public typealias E = Error
    
    private let _service: CloudService
    private let _cache: Provider
    private let _activityIndicator: ActivityIndicator
    
    public init(service: CloudService, cache: Provider, activityIndicator: ActivityIndicator) {
        _service = service
        _cache = cache
        _activityIndicator = activityIndicator
    }
    
    public func executeCache(request: R?) -> Observable<Result<T, Error>> {
        return .empty()
    }
    
    public func execute(request: R?) -> Observable<Result<T, Error>> {
        return _service
            .get(request: request)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { result in
                switch result {
                case let .success(result):
                    if let detail = result.data?.address {
                        if request?.id != nil {
                            self._cache.update(model: detail)
                        } else {
                            self._cache.put(model: detail)
                        }
                    }
                default:
                    break
                }
            })
            .trackActivity(_activityIndicator)
    }
}

