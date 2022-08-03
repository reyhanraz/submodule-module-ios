//
//  GalleryAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 06/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire
import Platform

open class GalleryAPI {
    
    public init() { }
    
    public func deleteGallery(ids: [Int]) -> Observable<(Data?, HTTPURLResponse?)>{
        let query = ["ids": ids]
        return ServiceHelper.shared.request(Endpoint.pathGalleries,
                             method: HTTPMethod.delete,
                             parameter: query,
                             encoding: URLEncoding.queryString)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getGalleries(kind: NewProfile.Kind, id: String, page: Int, limit: Int, timestamp: TimeInterval?) -> Observable<(Data?, HTTPURLResponse?)>{
        
        var params: [String : Any] = [:]
        
        params["ownerId"] = id
        params["page"] = page
        params["limit"] = limit
        
        if let timestamp = timestamp {
            params["timestamp"] = timestamp * 1000
        }
        
        let endPoint: String
        
        if kind == .artisan{
            endPoint = Endpoint.artisanGalleries
        }else{
            endPoint = Endpoint.pathGalleries
        }
        
        return ServiceHelper.shared.request(endPoint,
                             parameter: params)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
