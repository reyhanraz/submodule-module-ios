//
//  UploadUseCaseProvider.swift
//  Upload
//
//  Created by Reyhan Rifqi Azzami on 25/05/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Platform
import Domain
import ServiceWrapper

public struct UploadUseCaseProvider: UseCase {
    
    public typealias R = UploadMediaRequest
    
    public typealias T = Detail<UploadConfirmation>
    
    public typealias E = Error
    
    private let _service: UploadCloudService
    private let _activityIndicator: ActivityIndicator?
    
    public init(service: UploadCloudService, activityIndicator: ActivityIndicator?) {
        _service = service
        _activityIndicator = activityIndicator
    }
    
    public func executeCache(request: R?) -> Observable<Result<T, Error>> {
        return .empty()
    }
    
    public func execute(request: R?) -> Observable<Result<T, Error>> {
        if let indicator = _activityIndicator {
            return _service.get(request: request).trackActivity(indicator)
        } else {
            return _service.get(request: request)
        }
    }
    
    public func confirm(typeId: String, fileName: String) -> Observable<Result<T, Error>> {
        if let indicator = _activityIndicator {
            return _service.confirmed(typeId: typeId, fileName: fileName)
                .trackActivity(indicator)
        } else {
            return _service.confirmed(typeId: typeId, fileName: fileName)
        }
    }
    
}
