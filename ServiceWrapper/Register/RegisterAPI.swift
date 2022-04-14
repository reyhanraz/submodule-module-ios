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
        return super.request(Endpoint.register,
                             method: .post,
                             parameter: request,
                             encoding: JSONEncoding.default,
                             isBasicAuth: true)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func checkUser(request: CheckUserRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        guard !request.identifier.isEmpty else {
            return Observable.create { observer in
                observer.onNext((nil, nil))
                observer.onCompleted()
                return Disposables.create()
            }
        }
        return super.request(Endpoint.findUser,
                             method: .post,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func requestOTP(request: ChallengerRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request(Endpoint.challenges,
                             method: .post,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func validateOTP(request: ChallengerRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request(Endpoint.validateChallenge,
                             method: .post,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
}
