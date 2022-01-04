//
//  NewsApi.swift
//  News
//
//  Created by Fandy Gotama on 27/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum NewsApi {
    case getDetail(id: Int)
    case getList(page: Int, limit: Int, timestamp: TimeInterval?)
}

extension NewsApi: TargetType {
    
    public var baseURL: URL { return PlatformConfig.host }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .getDetail:
            return "\("config.serverless".l10n())news"
        default:
            return "\("config.serverless".l10n())newsList"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .getDetail(id):
            
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        case let .getList(page, limit, timestamp):
            var params: [String : Any] = [:]
            
            params["page"] = page
            params["limit"] = limit
            
            if let timestamp = timestamp {
                params["timestamp"] = timestamp * 1000
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
            
        }
    }
}
