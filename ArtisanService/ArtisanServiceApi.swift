//
//  ArtisanApi.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 24/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum ArtisanServiceApi {
    case getServices(id: Int?, page: Int, limit: Int, timestamp: TimeInterval?)
    case insert(request: ArtisanServiceRequest)
    case update(id: Int, request: ArtisanServiceRequest)
    case delete(id: Int)
}

extension ArtisanServiceApi: TargetType {
    
    public var baseURL: URL {
        return PlatformConfig.host
    }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .getServices:
            return "\("config.serverless".l10n())artisanServiceList"
        case .insert, .delete, .update:
            return "\("config.serverless".l10n())artisanService"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getServices:
            return .get
        case .insert:
            return .post
        case .update, .delete:
            return .put
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .getServices(id, page, limit, timestamp):
            var params: [String : Any] = [:]
            
            if let id = id {
                params["ownerId"] = id
            }
            
            params["page"] = page
            params["limit"] = limit
            
            if let timestamp = timestamp {
                params["timestamp"] = timestamp * 1000
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .delete(id):
            return .requestParameters(parameters: ["id": id, "status": "inactive"], encoding: JSONEncoding.default)
        case let .insert(request):
            return .requestJSONEncodable(request)
        case let .update(_, request):
            return .requestJSONEncodable(request)
        }
    }
}


