//
//  RegisterAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 17/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire
import L10n_swift

open class RegisterAPI: ServiceHelper{
    public override init(){
        super.init()
    }
    
    public func postRegister(request: RegisterRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request("accounts/register", method: .post ,parameters: request, encoding: JSONEncoding.default).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func checkUser(request: CheckUserRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request("api/v1/users/find", method: .post ,parameters: request, encoding: JSONEncoding.default).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func requestOTP(request: ChallengerRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request("api/challenges", method: .post ,parameters: request, encoding: JSONEncoding.default).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func validateOTP(request: ChallengerRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request("api/challenges/validate", method: .post ,parameters: request, encoding: JSONEncoding.default).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
}
