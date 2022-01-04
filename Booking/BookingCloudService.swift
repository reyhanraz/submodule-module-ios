//
//  BookingCloudService.swift
//  Booking
//
//  Created by Fandy Gotama on 30/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct BookingCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = BookingListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<BookingApi>
    
    public init(service: MoyaProvider<BookingApi> = MoyaProvider<BookingApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: BookingListRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Single<Response>
        
        if let id = request.id {
            response = _service.rx.request(.getDetail(id: id))
        } else {
            response = _service.rx.request(.getList(statuses: request.bookingStatuses?.map { $0.rawValue }, keyword: request.keyword, page: request.page, limit: 15, timestamp: request.timestamp))
        }
        
        return response
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
