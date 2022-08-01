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
import ServiceWrapper

public class BookingCloudService<CloudResponse: NewResponseType>: BookingAPI, ServiceType {
    public typealias R = BookingListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
            
    public func get(request: BookingListRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Observable<(Data?, HTTPURLResponse?)>
        
        if let id = request.id {
            response = super.getBookingDetail(id: id)
        } else {
            response = super.getBookingList(statuses: request.bookingStatuses?.map { $0.rawValue }, keyword: request.keyword, page: request.page, limit: 15, timestamp: request.timestamp)
        }
        
        return response
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
