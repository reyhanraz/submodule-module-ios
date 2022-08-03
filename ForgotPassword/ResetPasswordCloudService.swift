//
//  ResetPasswordCloudService.swift
//  ForgotPassword
//
//  Created by Reyhan Rifqi Azzami on 08/03/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import Foundation

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class ResetPasswordCloudService: ResetPasswordAPI, ServiceType {
    
    public typealias R = ServiceWrapper.ResetPasswordRequest
    
    public typealias T = Detail<BasicAPIResponse>
    public typealias E = Error
    
    
    public override init() {
        super.init()
    }
    
    public func get(request: ServiceWrapper.ResetPasswordRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        return super.resetPassword(request: request)
            .retry(3)
            .map { data, response in
                self.parse(data: data, statusCode: response?.statusCode)
            }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
