//
//  CheckEmailCloudService.swift
//  Registration
//
//  Created by Reyhan Rifqi Azzami on 17/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class CheckUserCloudService: RegisterAPI, ServiceType {
    public typealias R = CheckUserRequest

    public typealias T = CheckUser
    public typealias E = Error


    public override init() {
        super.init()
    }

    public func get(request: CheckUserRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return self.checkEmail(request: request).map { (data, response) in
            self.parse(data: data, statusCode: response?.statusCode)
        }
    }
}
