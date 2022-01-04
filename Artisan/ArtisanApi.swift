//
//  ArtisanApi.swift
//  Artisan
//
//  Created by Fandy Gotama on 07/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum ArtisanApi {
    case getDetail(id: Int)
    case getList(request: ArtisanFilter)
    case getFavoriteList(request: ArtisanFilter)
    case getNearby(request: ArtisanFilter)
}

extension ArtisanApi: TargetType {
    
    public var baseURL: URL { return PlatformConfig.host }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .getDetail:
            return "\("config.serverless".l10n())artisanProfile"
        case .getList:
            return "\("config.serverless".l10n())findArtisanList"
        case .getFavoriteList:
            return "\("config.serverless".l10n())artisanFavoriteList"
        case .getNearby:
            return "\("config.serverless".l10n())findArtisanNearby"
        }
    }
    
    public var method: Moya.Method {
        return .get
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .getDetail(id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        case let .getNearby(filter):
            var params: [String : Any] = [:]
            
            params["page"] = filter.page
            params["limit"] = filter.limit
            
            if let latitude = filter.latitude, let longitude = filter.longitude {
                params["range"] = 20
                params["lat"] = latitude
                params["lng"] = longitude
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .getFavoriteList(filter):
            var params: [String : Any] = [:]

            params["page"] = filter.page
            params["limit"] = filter.limit

            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)

        case let .getList(filter):
            var params: [String : Any] = [:]
            
            params["page"] = filter.page
            params["limit"] = filter.limit
            
            if let locations = filter.locations {
                params["districtIds"] = locations.map { $0.id }
            }
            
            if let ids = filter.categories {
                params["categoryIds"] = ids.map { $0.id }
            }
            
            if let ids = filter.categoryTypes {
                params["categoryTypeIds"] = ids.map { $0.id }
            }
            
            if let ratings = filter.ratings {
                params["ratings"] = ratings
            }
            
            if let min = filter.priceMin {
                params["priceMin"] = min
            }
            
            if let max = filter.priceMax {
                params["priceMax"] = max
            }
            
            if let search = filter.keyword {
                params["search"] = search
            }
            
            if let timestamp = filter.timestamp {
                params["timestamp"] = timestamp * 1000
            }
            
            if let latitude = filter.latitude, let longitude = filter.longitude {
                params["lat"] = latitude
                params["lon"] = longitude
            }

            if let isEditorChoice = filter.isEditorChoice {
                params["isEditorChoice"] = isEditorChoice
            }

            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
}
