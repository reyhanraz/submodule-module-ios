//
//  EventTrackingAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire
import Platform

open class EventTrackingAPI: ServiceHelper{
    
    public override init() {
        super.init()
    }
    
    public func trackEvent(userId: Int, type: User.Kind, eventName: String, token: String?, extraParams: [String : Any]?) -> Observable<(Data?, HTTPURLResponse?)>{
        
        var params: [String : Any] = [:]
        
        params["userId"] = userId
        params["type"] = type.rawValue
        params["eventName"] = eventName
        params["token"] = token

        if let extraParams = extraParams {
            params["eventParams"] = extraParams
        }
        
        return super.request(Endpoint.eventLog,
                             method: HTTPMethod.post,
                             parameter: params,
                             encoding: JSONEncoding.default)
            .retry(3).map { result in
                return (result.data, result.response)
            }
    }
}
