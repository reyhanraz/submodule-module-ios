//
//  UploadAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire
import L10n_swift
import Platform

open class UploadAPI: ServiceHelper{
    public override init() {
        super.init()
    }
    
    public func getSignedURL(request: UploadMediaRequest) -> Observable<MediaSigned>{
        return super.request(Endpoint.getSignedURL,
                             method: HTTPMethod.post,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            let media = try! JSONDecoder().decode(MediaSigned.self, from: result.data ?? Data())
            return media
        }
    }
    
    public func confirmed(uploadPath: String, request: UploadConfirmedRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request("\("config.path".l10n())Confirm\(uploadPath)Upload",
                             method: HTTPMethod.post,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func upload(mime: String, url: URL, path: URL) -> Observable<(Data?, HTTPURLResponse?)>{
        let header = HTTPHeaders(["Content-Type": mime])
        return super.upload(host: url, path: path, header: header).retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
