//
//  UpdateBookingStatusUseCaseProvider.swift
//  Booking
//
//  Created by Fandy Gotama on 31/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import RxSwift
import Domain

public enum StatusError: Error {
    case unavailable
}

public struct UpdateBookingStatusUseCaseProvider<CloudService: ServiceType, AvailabilityCloudService: ServiceType, Provider: Cache>: UseCase
    where
    CloudService.R == BookingListRequest, CloudService.T == BookingDetail, CloudService.E == Error,
    AvailabilityCloudService.R == CheckAvailabilityRequest, AvailabilityCloudService.T == Availability, AvailabilityCloudService.E == Error,
Provider.R == BookingListRequest, Provider.T == Booking {
    
    public typealias R = (bookingListRequest: BookingListRequest, checkAvailabilityRequest: CheckAvailabilityRequest?)
    public typealias T = CloudService.T
    public typealias E = Error
    
    private let _service: CloudService
    private let _availabilityService: AvailabilityCloudService?
    private let _cache: Provider?
    private let _activityIndicator: ActivityIndicator
    
    public init(service: CloudService, availabilityService: AvailabilityCloudService? = nil, cache: Provider?, activityIndicator: ActivityIndicator) {
        _service = service
        _availabilityService = availabilityService
        _cache = cache
        _activityIndicator = activityIndicator
    }
    
    public func executeCache(request: R?) -> Observable<Result<T, Error>> {
        return .empty()
    }
    
    public func execute(request: R?) -> Observable<Result<T, Error>> {
        let bookingListRequest = request?.bookingListRequest
        let checkAvailabilityRequest = request?.checkAvailabilityRequest
        
        if let availabilityService = _availabilityService, let checkAvailabilityRequest = checkAvailabilityRequest {
            return availabilityService
                .get(request: checkAvailabilityRequest)
                .flatMap { result -> Observable<Result<T, Error>> in
                    switch result {
                    case let .success(result):
                        if let availability = result.data?.available, !availability {
                            return Observable.just(Result.error(StatusError.unavailable))
                        } else {
                            return self.updateStatus(request: bookingListRequest)
                        }
                    default:
                        return self.updateStatus(request: bookingListRequest)
                    }
            }
        } else {
            return updateStatus(request: bookingListRequest)
        }
    }
    
    private func updateStatus(request: BookingListRequest?) -> Observable<Result<T, Error>> {
        return _service
            .get(request: request)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .do(onNext: { result in
                switch result {
                case let .success(result):
                    if let detail = result.data?.booking {
                        if let cache = self._cache, request?.id != nil {
//                            cache.update(model: detail)
                        }
                    }
                default:
                    break
                }
            })
            .trackActivity(_activityIndicator)
    }
}
