//
//  ChangePasswordApi.swift
//  ChangePassword
//
//  Created by Fandy Gotama on 21/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum ChangePasswordApi {
    case change(request: ChangePasswordRequest)
}

extension ChangePasswordApi: TargetType {
    
    public var baseURL: URL { return PlatformConfig.host }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        return "\("config.serverless".l10n())\("config.path".l10n())ChangePassword"
    }
    
    public var method: Moya.Method {
        return .put
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .change(request):
            return .requestJSONEncodable(request)
        }
    }
}

