//
//  NotificationCloudService.swift
//  Notification
//
//  Created by Fandy Gotama on 25/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class NotificationCloudService<CloudResponse: ResponseType>: NotificationAPI, ServiceType {
    public typealias R = ListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init(){
        super.init()
    }
    
    public func get(request: ListRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.getNotificationList(page: request.page, limit: request.limit, timestamp: request.timestamp)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
