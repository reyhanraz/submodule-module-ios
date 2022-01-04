//
//  CustomizeRequestApi.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 03/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum CustomizeRequestApi {
    case createCustomizedRequest(request: PostCustomRequest)
    case getList(page: Int, limit: Int, timestamp: TimeInterval?)
    case getDetail(id: Int)
}

extension CustomizeRequestApi: TargetType {
    
    public var baseURL: URL {
        return PlatformConfig.host
    }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .createCustomizedRequest:
            return "customRequest"
        case .getList:
            return "customRequestList"
        case .getDetail:
            return "customRequest"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .createCustomizedRequest:
            return .post
        case .getList, .getDetail:
            return .get
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .createCustomizedRequest(request):
            return .requestJSONEncodable(request)
        case let .getList(page, limit, timestamp):
            var params: [String : Any] = [:]
            
            params["page"] = page
            params["limit"] = limit
            
            if let timestamp = timestamp {
                params["timestamp"] = timestamp * 1000
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .getDetail(id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        }
    }
}
