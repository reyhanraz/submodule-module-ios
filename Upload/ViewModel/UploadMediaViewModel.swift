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
import ServiceWrapper

public struct UploadMediaViewModel {
   
    public typealias DataRequest = UploadMediaRequest
    public typealias DataResponse = Detail<UploadConfirmation>
    
    // MARK: Outputs
    public let confirm: Driver<Void>
    public let upload: Driver<Void>
    public let success: Driver<(DataRequest, DataResponse)>
    public let loading: Driver<(DataRequest, Loading)>
    public let failed: Driver<(DataRequest, Status.Detail)>
    public let exception: Driver<(DataRequest, Error)>
    public let unauthorized: Driver<Unauthorized>
    public let confirmUploadSuccess: Driver<(DataRequest, DataResponse)>
    public let confirmUploadFailed: Driver<(UploadMediaRequest, Status.Detail)>
    
    // MARK: Private
    private let _uploadProperty = PublishSubject<DataRequest>()
    private let _confirmProperty = PublishSubject<(UploadMediaRequest, String)>()
    
    public init(confirmAfterUpload: Bool = true) {
        let useCase = UploadUseCaseProvider(service: UploadCloudService(confirmAfterUpload: confirmAfterUpload), activityIndicator: nil)
        
        let loadingProperty = PublishSubject<(DataRequest, Loading)>()
        let exceptionProperty = PublishSubject<(DataRequest, Error)>()
        let failedProperty = PublishSubject<(DataRequest, Status.Detail)>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        let successProperty = PublishSubject<(DataRequest, DataResponse)>()
        let confirmUploadFailedProperty = PublishSubject<(UploadMediaRequest, Status.Detail)>()
        let confirmUploadSuccessProperty = PublishSubject<(DataRequest, DataResponse)>()

        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        confirmUploadFailed = confirmUploadFailedProperty.asDriver(onErrorDriveWith: .empty())
        confirmUploadSuccess = confirmUploadSuccessProperty.asDriver(onErrorDriveWith: .empty())
        
        upload = _uploadProperty.asDriver(onErrorDriveWith: .empty())
            .do(onNext: { request in loadingProperty.onNext((request, Loading(start: true, text: "uploading".l10n()))) })
            .flatMapLatest { request in
                return useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { result in loadingProperty.onNext((result.0, Loading(start: false))) })
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
        confirm = _confirmProperty.asDriver(onErrorDriveWith: .empty())
            .flatMapLatest({ (request, name) in
                return useCase.confirm(typeId: request.id, fileName: name).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }).flatMapLatest({ result in
                switch result.1 {
                case let .success(data):
                    confirmUploadSuccessProperty.onNext((result.0, data))
                case let .fail(status, _):
                    confirmUploadFailedProperty.onNext((result.0, status))
                case let .error(error):
                    confirmUploadFailedProperty.onNext((result.0, Status.Detail(code: 500, message: error.localizedDescription)))
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "", message: "", showLogin: false))
                }
                return .empty()
            })
    }
    
    public func upload(request: DataRequest) {
        _uploadProperty.onNext(request)
    }
    
    public func confirmUpload(request: UploadMediaRequest?, fileName: String?){
        guard let request = request, let fileName = fileName else { return }

        _confirmProperty.onNext((request, fileName))
    }
}



