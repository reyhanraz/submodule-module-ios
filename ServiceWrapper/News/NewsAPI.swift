//
//  NewsAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 06/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire

open class NewsAPI: ServiceHelper{
    
    public override init() {
        super.init()
    }
    
    public func getNewsList(page: Int, limit: Int, timestamp: TimeInterval?) -> Observable<(Data?, HTTPURLResponse?)>{
        
        var params: [String : Any] = [:]
        
        params["page"] = page
        params["limit"] = limit
        
        if let timestamp = timestamp {
            params["timestamp"] = timestamp * 1000
        }
        
        return super.request(Endpoint.newsList,
                             parameter: params)
            .retry(3).map { result in
                return (result.data, result.response)
            }
    }
    
    public func getNewsDetail(id: Int) -> Observable<(Data?, HTTPURLResponse?)>{
        
        var params: [String : Any] = [:]
        params["id"] = id
        
        return super.request(Endpoint.newsList,
                             parameter: params)
            .retry(3).map { result in
                return (result.data, result.response)
            }
    }
    
    
}
