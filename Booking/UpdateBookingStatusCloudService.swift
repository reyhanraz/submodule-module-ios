//
//  UpdateBookingStatusCloudService.swift
//  Booking
//
//  Created by Fandy Gotama on 31/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct UpdateBookingStatusCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = BookingListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<BookingApi>
    
    public init(service: MoyaProvider<BookingApi> = MoyaProvider<BookingApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: BookingListRequest?) -> Observable<Result<T, Error>> {
        guard let request = request,
            let id = request.id,
            let bookingStatuses = request.bookingStatuses,
            !bookingStatuses.isEmpty
            else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Single<Response>
        
        if request.bookingType == .booking {
            response = _service.rx.request(.updateBookingStatus(id: id, status: bookingStatuses[0]))
        } else {
            response = _service.rx.request(.updateCustomizeRequestStatus(id: id, artisanId: request.artisanId, price: request.bidPrice, status: bookingStatuses[0]))
        }
        
        return response
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
