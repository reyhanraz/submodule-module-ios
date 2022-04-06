//
//  ProfileAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 10/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import L10n_swift

open class ProfileAPI<R: Encodable>: ServiceHelper{
    public override init(){
        super.init()
    }
    
    public func getDetailProfile(request: Int?) -> Observable<(Data?, HTTPURLResponse?)>{
        var param: [String: Int] = [:]
        if let id = request{
            param["id"] = id
        }
        return super.request("\("config.path".l10n())Profile", parameter: param).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func updateProfile(request: R) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request("\("config.path".l10n())Profile",
                             method: HTTPMethod.put,
                             parameter: request,
                             encoding: JSONEncoding.default)
            .retry(3).map { result in
                return (result.data, result.response)
            }
    }
    
}
