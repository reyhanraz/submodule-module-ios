//
//  ResetPasswordAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 07/03/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire
import L10n_swift

open class ResetPasswordAPI {
    public init(){}
    
    public func resetPassword(request: ResetPasswordRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.resetPassword,
                             method: .post,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
