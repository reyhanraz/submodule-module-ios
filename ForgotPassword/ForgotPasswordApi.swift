//
//  ForgotPasswordApi.swift
//  ForgotPassword
//
//  Created by Fandy Gotama on 18/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum ForgotPasswordApi {
    case forgotPassword(request: ForgotPasswordRequest)
}

extension ForgotPasswordApi: TargetType {
    
    public var baseURL: URL { return PlatformConfig.host }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .forgotPassword:
            return "\("config.serverless".l10n())\("config.path".l10n())ResetPasswordSend"
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .forgotPassword(request):
            return .requestJSONEncodable(request)
        }
    }
}

