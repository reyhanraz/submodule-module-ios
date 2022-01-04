//
//  RegistrationApi.swift
//  Registration
//
//  Created by Fandy Gotama on 13/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum RegisterApi {
    case register(request: RegisterRequest)
}

extension RegisterApi: TargetType {
    
    public var baseURL: URL { return PlatformConfig.host }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .register:
            return "\("config.serverless".l10n())\("config.path".l10n())Register"
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .register(request):
            return .requestJSONEncodable(request)
        }
    }
}
