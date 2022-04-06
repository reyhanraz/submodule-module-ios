//
//  ForgotPasswordViewModel.swift
//  ForgotPassword
//
//  Created by Reyhan Rifqi Azzami on 04/03/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Domain
import L10n_swift
import Platform
import ServiceWrapper

public struct ForgotPasswordViewModel {
    public typealias Outputs = ForgotPasswordViewModel
    public typealias T = Detail<ForgotPasswordResponse>
    
    public var outputs: Outputs { return self }
    
    // MARK: - Outputs
    public let validatedEmail: Driver<ValidationResult>
    public let resetEnabled: Driver<Bool>
    public let failed: Driver<Alert>
    
    public let reset: Driver<Void>
    
    public let loading: Driver<Loading>
    public var exception: Driver<Exception>
    public let success: Driver<T>
    
    public let dismissResponder: Driver<Bool>
    
    public let _requestProperty = PublishSubject<ServiceWrapper.ForgotPasswordRequest>()
    
    public init<U: UseCase>(
        email: Driver<String>,
        useCase: U) where U.R == ServiceWrapper.ForgotPasswordRequest, U.T == T, U.E == Error {
        
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<T>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        let failedProperty = PublishSubject<Alert>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        dismissResponder = dismissResponderProperty.asDriver(onErrorJustReturn: false)
        
        validatedEmail = email.flatMapLatest { email in
            if email.isEmpty {
                return .just(.empty)
            } else if email.isValidEmail {
                return .just(.ok(message: nil))
            } else {
                return .just(.failed(message: "invalid_email".l10n()))
            }
        }
        
        resetEnabled = validatedEmail.map { $0.isValid }.distinctUntilChanged()
        
        reset = _requestProperty
                .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "resetting".l10n()))
                dismissResponderProperty.onNext(false)
            })
            .flatMapLatest { request in
                return useCase.execute(request: request).asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "reset_password".l10n())) })
            .flatMapLatest { result in
                switch result {
                case let .success(status):
                    successProperty.onNext(status)
                case let .fail(status, _):
                    failedProperty.onNext(Alert(title: "reset_password_failed".l10n(), message: status.message))
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "reset_password_failed".l10n(), message: "reset_password_error_message".l10n(), error: error))
                default:
                    return .empty()
                }
                
                return .empty()
        }
    }
    
    public func executeRequest(email: String?){
        guard let email = email else { return }

        let type = "config.path".l10n()
        let form = ServiceWrapper.ForgotPasswordRequest(email: email, type: type)
        _requestProperty.onNext(form)
    }
}
