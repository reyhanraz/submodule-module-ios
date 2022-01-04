//
//  CalendarApi.swift
//  Calendar
//
//  Created by Fandy Gotama on 20/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import Moya
import Common

public enum CalendarApi {
    case getEventList(start: Date?, end: Date?, artisanId: Int)
}

extension CalendarApi: TargetType {
    
    public var baseURL: URL {
        return PlatformConfig.host
    }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .getEventList:
            return "\("config.serverless".l10n())artisanCalendar"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getEventList:
            return .get
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .getEventList(start, end, artisanId):
            var params: [String : Any] = [:]
            
            params["artisanId"] = artisanId
            
            if let start = start {
                params["timeMin"] = start.toSystemDate
            }
            
            if let end = end {
                params["timeMax"] = end.toSystemDate
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
}
