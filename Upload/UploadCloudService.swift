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

public class UploadCloudService: UploadAPI, ServiceType {
    public typealias R = UploadMediaRequest
    
    public typealias T = Detail<UploadConfirmation>
    public typealias E = Error
    
    private let _confirmAfterUpload: Bool
    
    public init(confirmAfterUpload: Bool = true) {
        _confirmAfterUpload = confirmAfterUpload
    }
    
    public func get(request: UploadMediaRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response = super.createMedia(request: request)
            .retry(3)
            .asObservable()
        
        return response.flatMap { result -> Observable<Result<T, Error>> in
            if let result = result{
                return self.upload(request: request, signed: result)
            } else {
                return .just(Result<T,E>.fail(status: Status.Detail(code: 600, message: "Upload Failed"), errors: nil))
            }
        }
    }
    
    private func upload(request: UploadMediaRequest, signed: MediaSigned) -> Observable<Result<T, Error>> {
        guard let response = super.uploadFile(url: signed.url, request: request)?
            .retry(3)
            .asObservable()
        else {
            return .just(Result.fail(status: Status.Detail(code: 501, message: "Failed to Upload File"), errors: nil))
        }
        

        if _confirmAfterUpload {
            return response.flatMap { result -> Observable<Result<T, Error>> in
                if result.1?.statusCode == 200 {
                    return self.confirmed(typeId: request.id, fileName: signed.filename)
                } else {
                    return .just(.error(ServiceError.invalidRequest))
                }
            }
        } else {
            return response.map { (data, response) in
                if response?.statusCode == 200{
                    let mime: String
                    
                    if let data = request.data {
                        mime = data.mimeType
                    } else if let url = request.url {
                        mime = url.mimeType
                    } else { mime = "" }
                    
                    let model = UploadConfirmation(fileName: signed.filename,
                                                    mediaType: mime,
                                                    type: request.uploadType.rawValue,
                                                    uploaded: true,
                                                    typeID: request.id,
                                                    url: nil)
                    let detail = Detail(data: model)
                    
                    return Result<T,E>.success(detail)
                } else if let statusCode = response?.statusCode, let _ = data{
                    return Result<T,E>.fail(status: Status.Detail(code: statusCode, message: "Upload Failed"), errors: nil)
                } else {
                    return Result<T,E>.fail(status: Status.Detail(code: 500, message: "Connection Lost!"), errors: nil)
                }
            }
        }
    }
    
    public func confirmed(typeId: String, fileName: String) -> Observable<Result<T, Error>> {
        return super.confirmed(request: UploadConfirmedRequest(id: typeId, filename: fileName))
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
