//
//  ChangePasswordAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire

open class ChangePasswordAPI: ServiceHelper{
    
    public override init() {
        super.init()
    }
    
    public func postChangePassword(request: ChangePasswordRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request(Endpoint.changePassword,
                             method: HTTPMethod.put,
                             parameter: request,
                             encoding: JSONEncoding.default)
            .retry(3).map { result in
                return (result.data, result.response)
            }
    }
}
