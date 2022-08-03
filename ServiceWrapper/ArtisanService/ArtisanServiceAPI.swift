//
//  ArtisanServiceAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire

open class ArtisanServiceAPI{
    public init() {}
    
    public func getArtisanServiceList(request: ServiceListRequest?) -> Observable<(Data?, HTTPURLResponse?)>{

        return ServiceHelper.shared.request(Endpoint.artisanServices,
                             parameter: request)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func insertArtisanService(request: PostServiceRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.artisanServices,
                             method: HTTPMethod.post,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func updateArtisanService(id: String, request: PostServiceRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request("\(Endpoint.artisanServices)/\(id)",
                             method: HTTPMethod.patch,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func deleteArtisanService(id: String) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request("\(Endpoint.artisanServices)/\(id)",
                             method: HTTPMethod.delete,
                             parameter: nil,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func gatArtisanService(id: String) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request("\(Endpoint.artisanServices)/\(id)",
                             method: HTTPMethod.get,
                             parameter: nil,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
