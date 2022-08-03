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

open class UploadAPI {
    public init() { }
        
    public func createMedia(request: UploadMediaRequest) -> Observable<MediaSigned?> {
        var mime = ""
        
        if let url = request.url{
            mime = url.mimeType
        } else if let data = request.data {
            mime = data.mimeType
        }
        
        let body = ["mime_type": mime]
        return ServiceHelper.shared.request("\(Endpoint.createMedia)/\(request.uploadType.rawValue)",
                             method: HTTPMethod.post,
                             parameter: body,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            if let media = try? JSONDecoder().decode(Detail<MediaSigned>.self, from: result.data ?? Data()){
                return media.data
            } else {
                return nil
            }
        }
    }
    
    public func uploadFile(url: URL, request: UploadMediaRequest) -> Observable<(Data?, HTTPURLResponse?)>?{
        
        if let path = request.url{
            return ServiceHelper.shared.upload(host: url, path: path).retry(3).map { result in
                return (result.data, result.response)
            }
        } else if let data = request.data{
            return ServiceHelper.shared.upload(host: url, data: data).retry(3).map { result in
                return (result.data, result.response)
            }
        }
        
        return nil
    }
    
    public func confirmed(request: UploadConfirmedRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.confirmUpload,
                             method: HTTPMethod.patch,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func confirmed(request: [UploadConfirmedRequest]) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.confirmArrayUpload,
                             method: HTTPMethod.patch,
                             parameter: request,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
