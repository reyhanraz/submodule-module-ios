//
//  ResendEmailVerificationViewModel.swift
//  Profile
//
//  Created by Reyhan Rifqi Azzami on 28/05/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Domain
import Common
import UIKit
import ServiceWrapper

public struct ResendEmailVerificationViewModel {
    private let _submitProperty = PublishSubject<()>()
        
    public let loading: Driver<Loading>
    public let result: Driver<BasicAPIResponse>
    public let failed: Driver<Status.Detail>
    public let exception: Driver<Error>
    public let unauthorized: Driver<Unauthorized>

    public init<U: UseCase>(useCase: U) where U.R == Int, U.T == Detail<BasicAPIResponse>, U.E == Error {
        let exceptionProperty = PublishSubject<Error>()
        let failedProperty = PublishSubject<Status.Detail>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        let loadingProperty = PublishSubject<Loading>()
        
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        
        result = _submitProperty.asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: true, text: "submitting".l10n())) })
            .flatMap { _ in
                return useCase.execute(request: nil).map { $0 }.asDriver(onErrorDriveWith: .empty()) }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<BasicAPIResponse> in
                switch result {
                case let .success(data):
                    return .just(data.data)
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "submit_failed".l10n()))
                    
                    return .empty()
                case let .fail(status, _):
                    failedProperty.onNext(status)
                    
                    return .empty()
                case let .error(error):
                    exceptionProperty.onNext(error)
                    
                    return .empty()
                }
            })
    }
    
    public func submit(){
        _submitProperty.onNext(())
    }
}
