//
//  LoginAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 10/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire

open class LoginAPI{
    public init(){
    }
    
    public func requstLogin(request: LoginRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.login, method: .post ,parameter: request, isBasicAuth: true).retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
