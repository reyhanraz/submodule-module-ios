//
//  SetNotificationStatusCloudService.swift
//  Notification
//
//  Created by Fandy Gotama on 29/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class SetNotificationStatusCloudService<CloudResponse: ResponseType>: NotificationAPI, ServiceType {
    public typealias R = [Int]
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init(){
        super.init()
    }
    
    public func get(request: [Int]?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.setNotificationRead(ids: request)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
