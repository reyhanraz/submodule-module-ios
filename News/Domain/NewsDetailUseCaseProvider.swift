//
//  NewsDetailUseCaseProvider.swift
//  News
//
//  Created by Fandy Gotama on 27/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import RxSwift
import Domain

public struct NewsDetailUseCaseProvider<Service, R, Provider: Cache>: UseCase
    where
    Service: ServiceType, Service.R == R, Service.T == NewsDetail, Service.E == Error,
Provider.R == R, Provider.T == News {
    
    public typealias R = R
    public typealias E = Error
    
    private let _service: Service
    private let _cache: Provider
    private let _activityIndicator: ActivityIndicator
    
    public init(service: Service, cache: Provider, activityIndicator: ActivityIndicator) {
        _service = service
        _cache = cache
        _activityIndicator = activityIndicator
    }
    
    public func executeCache(request: R?) -> Observable<Result<Service.T, Error>> {
        return .empty()
    }
    
    public func execute(request: R?) -> Observable<Result<Service.T, Error>> {
        return _service
            .get(request: request)
            .trackActivity(_activityIndicator)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { result in
                if case let Result.success(type) = result, let news = type.data?.news {
                    self._cache.update(model: news)
                }
            })
    }
}
