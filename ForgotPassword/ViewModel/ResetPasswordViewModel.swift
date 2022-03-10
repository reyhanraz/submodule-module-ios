//
//  ResetPasswordViewModel.swift
//  ForgotPassword
//
//  Created by Reyhan Rifqi Azzami on 07/03/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Domain
import L10n_swift
import Platform
import ServiceWrapper

public struct ResetPasswordViewModel {
    public typealias Outputs = ResetPasswordViewModel
    public typealias T = Detail<ForgotPasswordResponse>
    
    public var outputs: Outputs { return self }
    
    // MARK: - Outputs
    public let validatedPassword: Driver<ValidationResult>
    public let validatedPasswordConfirmation: Driver<ValidationResult>
    public let resetEnabled: Driver<Bool>
    public let failed: Driver<Alert>
    
    public let reset: Driver<Void>
    
    public let loading: Driver<Loading>
    public var exception: Driver<Exception>
    public let success: Driver<T>
    
    public let dismissResponder: Driver<Bool>
        
    public init<U: UseCase>(
        token: String,
        password: Driver<String>,
        passwordConfirmation: Driver<String>,
        resetSignal: Signal<()>,
        useCase: U) where U.R == ServiceWrapper.ResetPasswordRequest, U.T == T, U.E == Error {
        
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
        
        validatedPassword = password.flatMapLatest { value in
            if value.isEmpty {
                return .just(.empty)
            } else if !value.validPassword {
                return .just(.failed(message: "invalid_password".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedPasswordConfirmation = Driver.combineLatest(password, passwordConfirmation) { password, confirmation in
            if confirmation.isEmpty {
                return .empty
            } else if password != confirmation {
                return .failed(message: "invalid_confirmation".l10n())
            } else {
                return .ok(message: nil)
            }
        }
        
        resetEnabled = Driver.combineLatest(validatedPassword, validatedPasswordConfirmation) { password, confirmation in
            password.isValid && confirmation.isValid
        }
    
        
        reset = resetSignal.withLatestFrom(password)
            .do(onNext: { _ in
            loadingProperty.onNext(Loading(start: true, text: "resetting".l10n()))
            dismissResponderProperty.onNext(false)
        })
        .flatMapLatest { password in
            return useCase.execute(request: ResetPasswordRequest(token: token, password: password)).asDriver(onErrorDriveWith: .empty())
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
}
