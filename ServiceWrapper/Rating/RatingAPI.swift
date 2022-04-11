//
//  RatingAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire
import L10n_swift


open class RatingAPI: ServiceHelper{
    public override init(){
        super.init()
    }
    
    public func getRatingList(artisanId: Int, page: Int, limit: Int, timestamp: TimeInterval?) -> Observable<(Data?, HTTPURLResponse?)>{
        var params: [String : Any] = [:]
        
        params["artisanId"] = artisanId
        params["page"] = page
        params["limit"] = limit
        
        if let timestamp = timestamp {
            params["timestamp"] = timestamp * 1000
        }
        
        return super.request(Endpoint.getRatingList,
                             parameter: params)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func giveRating(request: RatingRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request(Endpoint.giveRating,
                             method: HTTPMethod.post,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
