//
//  UploadApi.swift
//  Upload
//
//  Created by Fandy Gotama on 03/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum UploadApi {
    case getSignedURL(request: UploadMediaRequest)
    case upload(mime: String, url: URL, path: URL)
    case confirmed(uploadPath: String, request: UploadConfirmedRequest)
}

extension UploadApi: TargetType {
    
    public var baseURL: URL {
        switch self {
        case let .upload(_, url, _):
            return url
        default:
            return PlatformConfig.host
        }
    }
    
    public var headers: [String : String]? {
        switch self {
        case let .upload(mime, _, _):
            return ["Content-Type": mime]
        default:
            return PlatformConfig.httpHeaders
        }
    }
    
    public var path: String {
        switch self {
        case .getSignedURL:
            return "\("config.serverless".l10n())uploadSignedUrl"
        case let .confirmed(uploadPath, _):
            return "\("config.serverless".l10n())\("config.path".l10n())Confirm\(uploadPath)Upload"
        default:
            return ""
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .upload:
            return .put
        default:
            return .post
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .getSignedURL(request):
            return .requestJSONEncodable(request)
        case let .upload(_, _, path):
            return .uploadFile(path)
        case let .confirmed(_, request):
            return .requestJSONEncodable(request)
        }
    }
}
