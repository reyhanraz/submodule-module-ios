//
//  PostComplaintCloudService.swift
//  Booking
//
//  Created by Fandy Gotama on 11/01/21.
//  Copyright © 2021 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class PostComplaintCloudService<CloudResponse: ResponseType>: BookingAPI, ServiceType {
    public typealias R = PostComplaintRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public func get(request: PostComplaintRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.complaint(request: request)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
