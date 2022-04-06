//
//  EventTrackingCloudService.swift
//  EventTracking
//
//  Created by Fandy Gotama on 12/11/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class EventTrackingCloudService<CloudResponse: ResponseType>: EventTrackingAPI, ServiceType {
    public typealias R = EventTrackingRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
        
    public override init(){
        super.init()
    }
    
    public func get(request: EventTrackingRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.trackEvent(userId: request.userId, type: request.type, eventName: request.eventName, token: request.token, extraParams: request.extraParams)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
