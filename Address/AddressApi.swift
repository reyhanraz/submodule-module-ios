//
//  AddressApi.swift
//  Address
//
//  Created by Fandy Gotama on 29/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum AddressApi {
    case insert(request: AddressRequest)
    case update(id: Int, request: AddressRequest)
    case delete(id: Int)
    case getAddressList
    case searchLocation(keyword: String)
    case getProvinceList
    case updateLocation(lat: Double, lon: Double)
}

extension AddressApi: TargetType {
    
    public var baseURL: URL {
        return PlatformConfig.host
    }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .getAddressList:
            return "\("config.serverless".l10n())\("config.path".l10n())Addresses"
        case .insert, .delete, .update:
            return "\("config.serverless".l10n())\("config.path".l10n())Address"
        case .searchLocation:
            return "\("config.serverless".l10n())locationAreaList"
        case .getProvinceList:
            return "\("config.serverless".l10n())locationProvinceList"
        case .updateLocation:
            return "\("config.serverless".l10n())updateArtisanGeoLocation"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .delete:
            return .delete
        case .insert, .updateLocation:
            return .post
        case .update:
            return .put
        case .searchLocation, .getAddressList, .getProvinceList:
            return .get
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case .getAddressList:
            return .requestParameters(parameters: ["page": 1], encoding: URLEncoding.queryString)
        case let .insert(request):
            return .requestJSONEncodable(request)
        case let .update(_, request):
            return .requestJSONEncodable(request)
        case let .delete(id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        case let .searchLocation(keyword):
            return .requestParameters(parameters: ["search": keyword, "limit": 50], encoding: URLEncoding.queryString)
        case .getProvinceList:
            return .requestParameters(parameters: ["page": 1, "limit": 10000], encoding: URLEncoding.queryString)
        case let .updateLocation(lat, lon):
            return .requestParameters(parameters: ["lat": lat, "lng": lon], encoding: JSONEncoding.default)
        }
    }
}

