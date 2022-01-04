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

public enum CategoryApi {
    case getCategories
}

extension CategoryApi: TargetType {
    
    public var baseURL: URL { return URL(fileURLWithPath: "config.domain".l10n()) }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .getCategories:
            return "api/service-categories"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        return .requestPlain
    }
}
