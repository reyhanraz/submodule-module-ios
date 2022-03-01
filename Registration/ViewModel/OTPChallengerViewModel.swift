//
//  OTPChallengerViewModel.swift
//  Registration
//
//  Created by Reyhan Rifqi Azzami on 19/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Platform
import Domain
import ServiceWrapper

public struct OTPChallengerViewModel{
    
    public let challenger: Driver<Void>
    
    public let loading: Driver<Loading>
    public let failed: Driver<(Status.Detail, [DataError]?)>
    public let exception: Driver<Exception>
    public let success: Driver<Detail<ChallengerRequest>>
        
    private let _requestProperty = PublishSubject<ChallengerRequest?>()

    
    public init<U: UseCase>(
        useCase: U) where U.R == ChallengerRequest, U.T == Detail<ChallengerRequest>, U.E == Error {
            
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<Detail<ChallengerRequest>>()
        let failedProperty = PublishSubject<(Status.Detail, [DataError]?)>()
        let exceptionProperty = PublishSubject<Exception>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
            
        challenger = _requestProperty.asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "registering".l10n()))
            })
            .flatMapLatest { request in
                return useCase.execute(request: request).asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "register".l10n())) })
            .flatMapLatest { result in
                switch result {
                case let .success(register):
                    successProperty.onNext(register)
                case let .fail(status, errors):
                    failedProperty.onNext((status, errors))
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "registration_failed".l10n(), message: "registration_error_message".l10n(), error: error))
                default:
                    return .empty()
                }
                
                return .empty()
        }
    }
    
    public func execute(request: ChallengerRequest? = nil) {
        _requestProperty.onNext(request)
    }
}
