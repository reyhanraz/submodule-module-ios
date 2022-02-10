//
//  NewLoginCloudService.swift
//  Login
//
//  Created by Reyhan Rifqi Azzami on 10/02/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import L10n_swift
import Platform
import ServiceWrapper

public class NewLoginCloudService: LoginAPI, ServiceType {
    
    public typealias R = ServiceWrapper.LoginRequest
    public typealias T = Token
    public typealias E = Error
    
    
    public override init() {
        super.init()
    }
    
    public func get(request: ServiceWrapper.LoginRequest?) -> Observable<Result<Token, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        return requstLogin(request: request).map { (data, response) in
            self.parse(data: data, statusCode: response?.statusCode)
        }
    }
}
