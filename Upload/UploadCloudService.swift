//
//  UploadCloudService.swift
//  Upload
//
//  Created by Fandy Gotama on 05/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Platform
import ServiceWrapper

public class UploadCloudService<CloudResponse: ResponseType>: UploadAPI, ServiceType {
    public typealias R = UploadMediaRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _confirmAfterUpload: Bool
    
    public init(confirmAfterUpload: Bool = true) {
        _confirmAfterUpload = confirmAfterUpload
    }
    
    public func get(request: UploadMediaRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response = super.getSignedURL(request: request)
            .retry(3)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
        
        return response.flatMap { result -> Observable<Result<T, Error>> in
            switch result {
            case let .success(response):
                if let signed = response.data?.signed {
                    return self.upload(request: request, signed: signed)
                } else {
                    return .just(.error(ServiceError.invalidRequest))
                }
            default:
                return .just(.error(ServiceError.invalidRequest))
            }
        }
    }
    
    private func upload(request: UploadMediaRequest, signed: MediaSigned.Signed) -> Observable<Result<T, Error>> {
        let response = super.upload(mime: request.mimeType, url: signed.url, path: request.url)
            .retry(3)
            .asObservable()

        if _confirmAfterUpload {
            return response.flatMap { result -> Observable<Result<T, Error>> in
                if result.1?.statusCode == 200 {
                    return self.confirmed(request: request, signed: signed)
                } else {
                    return .just(.error(ServiceError.invalidRequest))
                }
            }
        } else {
            return response
                .map { Status(status: Status.Detail(code: $0.1?.statusCode ?? 404, message: "")) as! CloudResponse }
                .map { response in self.parse(result: response) }
                .catchError { error in return .just(.error(error)) }
        }
    }
    
    private func confirmed(request: UploadMediaRequest, signed: MediaSigned.Signed) -> Observable<Result<T, Error>> {
        return super.confirmed(uploadPath: request.uploadType.rawValue, request: UploadConfirmedRequest(id: request.id, temporaryObjectName: signed.temporaryObjectName))
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
