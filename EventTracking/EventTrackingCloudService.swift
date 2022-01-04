//
//  EventTrackingCloudService.swift
//  EventTracking
//
//  Created by Fandy Gotama on 12/11/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct EventTrackingCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = EventTrackingRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<EventTrackingApi>
    
    public init(service: MoyaProvider<EventTrackingApi> = MoyaProvider<EventTrackingApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: EventTrackingRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx
            .request(.trackEvent(userId: request.userId, type: request.type, eventName: request.eventName, token: request.token, extraParams: request.extraParams))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
