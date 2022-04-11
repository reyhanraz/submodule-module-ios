//
//  ArtisanServiceAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire

open class ArtisanServiceAPI: ServiceHelper{
    public override init() {
        super.init()
    }
    
    public func getArtisanServiceList(id: Int?, page: Int, limit: Int, timestamp: TimeInterval?) -> Observable<(Data?, HTTPURLResponse?)>{
        var params: [String : Any] = [:]
        
        if let id = id {
            params["ownerId"] = id
        }
        
        params["page"] = page
        params["limit"] = limit
        
        if let timestamp = timestamp {
            params["timestamp"] = timestamp * 1000
        }
        
        return super.request(Endpoint.artisanServicesList,
                             parameter: params)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func insertArtisanService(request: ArtisanServiceRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request(Endpoint.artisanServicesDetail,
                             method: HTTPMethod.post,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func updateArtisanService(id: Int, request: ArtisanServiceRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request(Endpoint.artisanServicesDetail,
                             method: HTTPMethod.put,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func deleteArtisanService(id: Int) -> Observable<(Data?, HTTPURLResponse?)>{
        let parameters: [String : Any] = ["id": id, "status": "inactive"]
        return super.request(Endpoint.artisanServicesDetail,
                             method: HTTPMethod.put,
                             parameter: parameters,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    
}
