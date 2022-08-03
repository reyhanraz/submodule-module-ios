//
//  ConfirmUploadCloudService.swift
//  Upload
//
//  Created by Reyhan Rifqi Azzami on 07/07/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import Platform
import RxSwift
import RxCocoa

public class ConfirmUploadCloudService<Request, Response: Codable>: UploadAPI, ServiceType {
    public typealias R = Request
    
    public typealias T = Response
    public typealias E = Error
    
    
    public override init() {
        super.init()
    }
    
    public func get(request: R?) -> Observable<Result<T, Error>> {
        
        if let request = request as? UploadConfirmedRequest {
            return super.confirmed(request: request)
                .retry(3)
                .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
                .catchError { error in return .just(.error(error)) }
                .asObservable()
        } else if let request = request as? [UploadConfirmedRequest]{
            return super.confirmed(request: request)
                .retry(3)
                .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
                .catchError { error in return .just(.error(error)) }
                .asObservable()
        } else {
            return .just(.error(ServiceError.invalidRequest))
        }
        
        
    }
}
