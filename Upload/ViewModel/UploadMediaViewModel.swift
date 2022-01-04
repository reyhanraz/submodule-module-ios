//
//  UploadMediaViewModel.swift
//  Upload
//
//  Created by Fandy Gotama on 04/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Domain
import Common

public struct UploadMediaViewModel<DataRequest, DataResponse: ResponseType>: UploadMediaViewModelType {
   
    public typealias Request = DataRequest
    public typealias Response = DataResponse
    
    // MARK: Outputs
    public let upload: Driver<Void>
    public let success: Driver<(DataRequest, DataResponse)>
    public let loading: Driver<(DataRequest, Bool)>
    public let failed: Driver<(DataRequest, Status.Detail)>
    public let exception: Driver<(DataRequest, Error)>
    public let unauthorized: Driver<Unauthorized>
    
    // MARK: Private
    private let _uploadProperty = PublishSubject<DataRequest>()
    
    public init<U: UseCase>(useCase: U) where U.R == DataRequest, U.T == DataResponse, U.E == Error {
        
        let loadingProperty = PublishSubject<(DataRequest, Bool)>()
        let exceptionProperty = PublishSubject<(DataRequest, Error)>()
        let failedProperty = PublishSubject<(DataRequest, Status.Detail)>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        let successProperty = PublishSubject<(DataRequest, DataResponse)>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        
        upload = _uploadProperty.asDriver(onErrorDriveWith: .empty())
            .do(onNext: { request in loadingProperty.onNext((request, true)) })
            .flatMapLatest { request in
                return useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { result in loadingProperty.onNext((result.0, false)) })
            .flatMapLatest { result in
                switch result.1 {
                case let .success(data):
                    successProperty.onNext((result.0, data))
                case let .fail(status, _):
                    failedProperty.onNext((result.0, status))
                case let .error(error):
                    exceptionProperty.onNext((result.0, error))
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "", message: "", showLogin: false))
                }
                
                return .empty()
            }
    }
    
    public func upload(request: DataRequest) {
        _uploadProperty.onNext(request)
    }
}



