//
//  EventCacheService.swift
//  Calendar
//
//  Created by Fandy Gotama on 21/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import RxSwift

public struct EventCacheService<DataResponse: ResponseType, Provider: Cache>: ServiceType where Provider.R == CalendarRequest, Provider.T == Calendar.Event {
    
    public typealias R = Provider.R
    public typealias T = DataResponse
    public typealias E = Error
    
    private let _cache: Provider
    
    public init(cache: Provider) {
        _cache = cache
    }
    
    public func get(request: CalendarRequest?) -> Observable<Result<DataResponse, Error>> {
        let list = _cache.getList(request: request)
        
        let data = CalendarDetail.Data(calendar: Calendar(authorized: true, authURL: nil, events: list))
        
        let status = Status.Detail(code: 200, message: "")
        
        guard let model = CalendarDetail(status: status, data: data, errors: nil) as? DataResponse else { fatalError() }
        
        return Observable
            .just(model)
            .map(Result.success)
            .catchError { error in return .just(.error(error)) }
    }
}
