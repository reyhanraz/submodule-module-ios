//
//  EventUseCaseProvider.swift
//  Calendar
//
//  Created by Fandy Gotama on 21/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Platform
import Domain

public struct EventUseCaseProvider<CloudService: ServiceType, CacheService: ServiceType>: UseCase
    where
    CloudService.R == CalendarRequest, CloudService.T == CalendarDetail, CloudService.E == Error,
    CacheService.R == CalendarRequest, CacheService.T == CalendarDetail, CacheService.E == Error {
    
    public typealias R = CalendarRequest
    public typealias T = CalendarDetail
    public typealias E = Error
    
    private let _service: CloudService
    private let _cacheService: CacheService
    private let _cache: EventSQLCache
    private let _activityIndicator: ActivityIndicator?
    
    public init(service: CloudService, cacheService: CacheService, cache: EventSQLCache, activityIndicator: ActivityIndicator?) {
        _service = service
        _cacheService = cacheService
        _cache = cache
        _activityIndicator = activityIndicator
    }
    
    public func executeCache(request: CalendarRequest?) -> Observable<Result<CalendarDetail, Error>> {
        return _cacheService.get(request: request)
    }
    
    public func execute(request: CalendarRequest?) -> Observable<Result<CalendarDetail, Error>> {
        guard let request = request else { return Observable.empty() }
        
        if _cache.isCacheAvailable(request: request) == true && !request.forceReload {
            return _cacheService.get(request: request)
        } else {
            let response: Observable<Result<CalendarDetail, Error>>
            
            if let indicator = _activityIndicator {
                response = _service
                    .get(request: request)
                    .trackActivity(indicator)
            } else {
                response = _service
                    .get(request: request)
            }
            
            return response
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
                .do(onNext: { result in
                    if case let Result.success(type) = result {
                        if type.data?.calendar.authorized == true {
                            self._cache.remove(request: request)
                            
                            if let events = type.data?.calendar.events {
                                if events.isEmpty {
                                    self._cache.insertMonthYear(request: request)
                                } else {
                                    self._cache.putList(request: request, models: events)
                                }
                            }
                        }
                    }
                })
        }
    }
}

