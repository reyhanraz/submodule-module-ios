//
//  RatingApi.swift
//  Rating
//
//  Created by Fandy Gotama on 01/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum RatingApi {
    case giveRating(request: RatingRequest)
    case getList(artisanId: Int, page: Int, limit: Int, timestamp: TimeInterval?)
}

extension RatingApi: TargetType {
    
    public var baseURL: URL {
        return PlatformConfig.host
    }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .giveRating:
            return "\("config.serverless".l10n())artisanReview"
        case .getList:
            return "\("config.serverless".l10n())artisanReviewList"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .giveRating:
            return .post
        case .getList:
            return .get
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .giveRating(request):
            return .requestJSONEncodable(request)
        case let .getList(artisanId, page, limit, timestamp):
            var params: [String : Any] = [:]
            
            params["artisanId"] = artisanId
            params["page"] = page
            params["limit"] = limit
            
            if let timestamp = timestamp {
                params["timestamp"] = timestamp * 1000
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
}



