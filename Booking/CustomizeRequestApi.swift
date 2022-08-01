//
//  CustomizeRequestApi.swift
//  Booking
//
//  Created by Fandy Gotama on 15/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum CustomizeRequestApi {
    case createCustomizedRequest(request: PostCustomRequest)
    case updateCustomizedRequest(request: PostCustomRequest)
    case getBidder(id: Int)
    case getList(page: Int, limit: Int, timestamp: TimeInterval?)
    case getDetail(id: String)
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
        case .createCustomizedRequest, .updateCustomizedRequest:
            return "\("config.serverless".l10n())customRequest"
        case .getList:
            return "\("config.serverless".l10n())customRequestList"
        case .getDetail:
            return "\("config.serverless".l10n())customRequest"
        case .getBidder:
            return "\("config.serverless".l10n())customRequestBids"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .createCustomizedRequest:
            return .post
        case .updateCustomizedRequest:
            return .put
        case .getList, .getDetail, .getBidder:
            return .get
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .createCustomizedRequest(request):
            return .requestJSONEncodable(request)
        case let .updateCustomizedRequest(request):
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
        case let .getBidder(id):
            return .requestParameters(parameters: ["bookingId": id], encoding: URLEncoding.queryString)
        }
    }
}

