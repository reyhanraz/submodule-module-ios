//
//  NotificationAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 06/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire

open class NotificationAPI {
    
    public init() { }
    
    public func registerNotification(token: String) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.registerNotification,
                             method: HTTPMethod.post,
                             parameter: ["token": token, "source": "ios"],
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func setNotificationRead(ids: [Int]) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.notificationMessages,
                             method: HTTPMethod.put,
                             parameter: ["ids": ids, "status": "read"],
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func deleteNotification(id: Int) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.notificationMessages,
                             method: HTTPMethod.delete,
                             parameter: ["ids[]": id],
                             encoding: URLEncoding.queryString)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getNotificationList(page: Int, limit: Int, timestamp: TimeInterval?) -> Observable<(Data?, HTTPURLResponse?)>{
        var params: [String : Any] = [:]
        
        params["page"] = page
        params["limit"] = limit
        
        if let timestamp = timestamp {
            params["timestamp"] = timestamp * 1000
        }
        return ServiceHelper.shared.request(Endpoint.notificationMessages,
                             parameter: params)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getUnread() -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.notificationUnreadCount,
                             parameter: nil)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
