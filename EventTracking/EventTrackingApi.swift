//
//  EventTrackingApi.swift
//  EventTracking
//
//  Created by Fandy Gotama on 12/11/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum EventTrackingApi {
    case trackEvent(userId: Int, type: User.Kind, eventName: String, token: String?, extraParams: [String : Any]?)
}

extension EventTrackingApi: TargetType {
    public var baseURL: URL {
        return PlatformConfig.host
    }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .trackEvent:
            return "\("config.serverless".l10n())\("config.path".l10n())EventLog"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .trackEvent:
            return .post
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .trackEvent(userId, type, eventName, token, extraParams):
            var params: [String : Any] = [:]
            
            params["userId"] = userId
            params["type"] = type.rawValue
            params["eventName"] = eventName
            params["token"] = token

            if let extraParams = extraParams {
                params["eventParams"] = extraParams
            }
            
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
}
