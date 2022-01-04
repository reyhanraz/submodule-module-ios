//
//  FavoriteApi.swift
//  Favorite
//
//  Created by Fandy Gotama on 03/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum FavoriteApi {
    case add(artisanId: Int)
    case remove(artisanId: Int)
}

extension FavoriteApi: TargetType {
    
    public var baseURL: URL {
        return PlatformConfig.host
    }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .add:
            return "\("config.serverless".l10n())artisanFavoriteSet"
        case .remove:
            return "\("config.serverless".l10n())artisanFavoriteRemove"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .add, .remove:
            return .post
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .add(artisanId):
            return .requestParameters(parameters: ["artisanId": artisanId], encoding: JSONEncoding.default)
        case let .remove(artisanId):
            return .requestParameters(parameters: ["artisanId": artisanId], encoding: JSONEncoding.default)
        }
    }
}
