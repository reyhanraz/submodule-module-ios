//
//  ProfileApi.swift
//  Profile
//
//  Created by Fandy Gotama on 20/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum ProfileApi<R: Encodable> {
    case getDetail(id: Int)
    case update(request: R)
}

extension ProfileApi: TargetType {
    
    public var baseURL: URL { return PlatformConfig.host }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        return "\("config.serverless".l10n())\("config.path".l10n())Profile"
    }
    
    public var method: Moya.Method {
        switch self {
        case .getDetail:
            return .get
        case .update:
            return .put
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .getDetail(id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        case let .update(request):
            return .requestJSONEncodable(request)
        }
    }
}
