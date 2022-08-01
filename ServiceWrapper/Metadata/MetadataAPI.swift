//
//  MetadataAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 27/05/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire
import L10n_swift
import Platform

open class MetadataAPI{
    public init() { }
        
    public func addMetadata(request: MetadataRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.metadata,
                             method: .post,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func editMetadata(request: MetadataRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.metadata,
                             method: .patch,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
