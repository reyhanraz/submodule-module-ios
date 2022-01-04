//
//  GalleryApi.swift
//  Gallery
//
//  Created by Fandy Gotama on 13/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum GalleryApi {
    case getGalleries(kind: User.Kind, id: Int, page: Int, limit: Int, timestamp: TimeInterval?)
    case deleteGalleries(ids: [Int])
}

extension GalleryApi: TargetType {
    
    public var baseURL: URL { return PlatformConfig.host }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case let .getGalleries(kind, _, _, _, _):
            if kind == .artisan {
                return "\("config.serverless".l10n())artisanGalleryItems"
            } else {
                return "\("config.serverless".l10n())\("config.path".l10n())GalleryItems"
            }
        case .deleteGalleries:
            return "\("config.serverless".l10n())\("config.path".l10n())GalleryItems"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getGalleries:
            return .get
        case .deleteGalleries:
            return .delete
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .getGalleries(_, id, page, limit, timestamp):
            var params: [String : Any] = [:]
            
            params["ownerId"] = id
            params["page"] = page
            params["limit"] = limit
            
            if let timestamp = timestamp {
                params["timestamp"] = timestamp * 1000
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .deleteGalleries(ids):
            return .requestParameters(parameters: ["ids": ids], encoding: URLEncoding.queryString)
            
        }
    }
}
