//
//  ForgotPasswordCloudService.swift
//  ForgotPassword
//
//  Created by Reyhan Rifqi Azzami on 04/03/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class ForgotPasswordCloudService: ForgotPasswordAPI, ServiceType {
    
    public typealias R = ServiceWrapper.ForgotPasswordRequest
    
    public typealias T = Detail<ForgotPasswordResponse>
    public typealias E = Error
    
    
    public override init() {
        super.init()
    }
    
    public func get(request: ServiceWrapper.ForgotPasswordRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        return super.forgotPassword(request: request)
            .retry(3)
            .map { data, response in
                self.parse(data: data, statusCode: response?.statusCode)
            }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
