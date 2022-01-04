//
//  NotificationApi.swift
//  Notification
//
//  Created by Fandy Gotama on 25/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum NotificationApi {
    case register(token: String)
    case getList(page: Int, limit: Int, timestamp: TimeInterval?)
    case delete(id: Int)
    case getUnread
    case setRead(ids: [Int])
}

extension NotificationApi: TargetType {
    
    public var baseURL: URL {
        return PlatformConfig.host
    }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .register:
            return "\("config.serverless".l10n())\("config.path".l10n())PushToken"
        case .getList, .setRead, .delete:
            return "\("config.serverless".l10n())\("config.path".l10n())NotificationMessages"
        case .getUnread:
            return "\("config.serverless".l10n())\("config.path".l10n())NotificationUnreadCount"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .register:
            return .post
        case .delete:
            return .delete
        case .getList, .getUnread:
            return .get
        case .setRead:
            return .put
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .register(token):
            return .requestParameters(parameters: ["token": token, "source": "ios"], encoding: JSONEncoding.default)
        case let .delete(id):
            return .requestParameters(parameters: ["ids[]": id], encoding: URLEncoding.queryString)
        case let .getList(page, limit, timestamp):
            var params: [String : Any] = [:]
            
            params["page"] = page
            params["limit"] = limit
            
            if let timestamp = timestamp {
                params["timestamp"] = timestamp * 1000
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .setRead(ids):
            return .requestParameters(parameters: ["ids": ids, "status": "read"], encoding: JSONEncoding.default)
        case .getUnread:
            return .requestPlain
        }
    }
}

