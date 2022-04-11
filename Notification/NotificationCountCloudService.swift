//
//  NotificationCountCloudService.swift
//  Notification
//
//  Created by Fandy Gotama on 29/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class NotificationCountCloudService<CloudResponse: ResponseType>: NotificationAPI, ServiceType {
    public typealias R = Any
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init(){
        super.init()
    }
    
    public func get(request: Any?) -> Observable<Result<T, Error>> {
        return super.getUnread()
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

