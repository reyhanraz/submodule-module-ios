//
//  CategoryApi.swift
//  Category
//
//  Created by Fandy Gotama on 18/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum CategoryApi {
    case getCategories
    case getCategoryTypes
}

extension CategoryApi: TargetType {
    
    public var baseURL: URL { return PlatformConfig.host }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .getCategories:
            return "\("config.serverless".l10n())serviceCategoryList"
        case .getCategoryTypes:
            return "\("config.serverless".l10n())serviceCategoryTypeList"
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
