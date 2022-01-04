//
//  LoginApi.swift
//  Login
//
//  Created by Fandy Gotama on 14/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum LoginApi {
    case login(request: LoginRequest)
}

extension LoginApi: TargetType {
    
    public var baseURL: URL { return PlatformConfig.host }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .login:
            return "\("config.serverless".l10n())\("config.path".l10n())Login"
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .login(request):
            return .requestJSONEncodable(request)
        }
    }
}
