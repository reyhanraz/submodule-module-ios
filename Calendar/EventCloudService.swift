//
//  EventCloudService.swift
//  Calendar
//
//  Created by Fandy Gotama on 20/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct EventCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = CalendarRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<CalendarApi>
    
    public init(service: MoyaProvider<CalendarApi> = MoyaProvider<CalendarApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: CalendarRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx.request(.getEventList(start: request.start, end: request.end, artisanId: request.artisanId))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

