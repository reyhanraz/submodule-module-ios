//
//  ChangePasswordCloudService.swift
//  ChangePassword
//
//  Created by Fandy Gotama on 21/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class ChangePasswordCloudService<CloudResponse: ResponseType>: ChangePasswordAPI, ServiceType {
    public typealias R = ChangePasswordRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
        
    public override init() {
        super.init()
    }
    
    public func get(request: ChangePasswordRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.postChangePassword(request: request)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
