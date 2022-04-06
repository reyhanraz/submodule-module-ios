//
//  EventCloudService.swift
//  Calendar
//
//  Created by Fandy Gotama on 20/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class EventCloudService<CloudResponse: ResponseType>: CalendarAPI, ServiceType {
    public typealias R = CalendarRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init() {
        super.init()
    }
    
    public func get(request: CalendarRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.getEventList(start: request.start, end: request.end, artisanId: request.artisanId)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

