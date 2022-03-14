//
//  ForgotPasswordAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 04/03/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire
import L10n_swift

open class ForgotPasswordAPI: ServiceHelper{
    public override init(){
        super.init()
    }
    
    public func forgotPassword(request: ForgotPasswordRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request(Endpoint.forgotPassword, method: .post ,parameters: request, encoding: JSONEncoding.default, isBasicAuth: true).retry(3).map { result in
            return (result.data, result.response)
        }
    }
}