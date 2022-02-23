//
//  NewRegisterCloudService.swift
//  Registration
//
//  Created by Reyhan Rifqi Azzami on 22/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class NewRegisterCloudService: RegisterAPI, ServiceType {
    public typealias R = ServiceWrapper.RegisterRequest

    public typealias T = RegisterResponse
    public typealias E = Error


    public override init() {
        super.init()
    }
    
    public func get(request: ServiceWrapper.RegisterRequest?) -> Observable<Result<RegisterResponse, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }

        return self.postRegister(request: request).map { (data, response) in
            self.parse(data: data, statusCode: response?.statusCode)
        }
    }

}
