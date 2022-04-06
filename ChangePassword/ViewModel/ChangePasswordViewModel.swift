//
//  ChangePasswordViewModel.swift
//  ChangePassword
//
//  Created by Fandy Gotama on 21/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common
import Domain
import ServiceWrapper

public struct ChangePasswordViewModel<T: ResponseType>: ChangePasswordViewModelType, ChangePasswordViewModelOutput {
    public typealias Outputs = ChangePasswordViewModel<T>
    
    public var outputs: Outputs { return self }
    
    public let validatedCurrentPassword: Driver<ValidationResult>
    public let validatedNewPassword: Driver<ValidationResult>
    public let validatedPasswordConfirmation: Driver<ValidationResult>
    public let changeEnabled: Driver<Bool>
    public let loading: Driver<Loading>
    public let change: Driver<Void>
    public let success: Driver<T>
    public let failed: Driver<Alert>
    public let exception: Driver<Exception>
    public let unauthorized: Driver<Unauthorized>
    public let dismissResponder: Driver<Bool>
    
    public init<U: UseCase>(
        password: Driver<String>,
        newPassword: Driver<String>,
        newPasswordConfirmation: Driver<String>,
        changeSignal: Signal<()>,
        useCase: U) where U.R == ChangePasswordRequest, U.T == T, U.E == Error {
        
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<T>()
        let failedProperty = PublishSubject<Alert>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        dismissResponder = dismissResponderProperty.asDriver(onErrorJustReturn: false)
        
        validatedCurrentPassword = password.flatMapLatest { value in
            if value.isEmpty {
                return .just(.empty)
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedNewPassword = Driver.combineLatest(password, newPassword) { password, newPassword in
            if newPassword.isEmpty {
                return .empty
            } else if !newPassword.validPassword {
                return .failed(message: "invalid_password".l10n())
            } else if newPassword == password {
                return .failed(message: "new_password_equal_to_current".l10n())
            } else {
                return .ok(message: nil)
            }
        }
        
        validatedPasswordConfirmation = Driver.combineLatest(newPassword, newPasswordConfirmation) { newPassword, confirmation in
            if confirmation.isEmpty {
                return .empty
            } else if newPassword != confirmation {
                return .failed(message: "invalid_confirmation".l10n())
            } else {
                return .ok(message: nil)
            }
        }
        
        changeEnabled = Driver.combineLatest(validatedCurrentPassword, validatedNewPassword, validatedPasswordConfirmation) {
            currentPassword, password, confirmation in
            
            currentPassword.isValid && password.isValid && confirmation.isValid
            }.distinctUntilChanged()
        
        let forms = Driver.combineLatest(password, newPassword, newPasswordConfirmation) {
            (password, newPassword, newPasswordConfirmation) -> ChangePasswordRequest in
            
            ChangePasswordRequest(password: password, newPassword: newPassword)
        }
        
        change = changeSignal.withLatestFrom(forms)
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "updating".l10n()))
                dismissResponderProperty.onNext(true)
            })
            .flatMapLatest { request in
                return useCase.execute(request: request).asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "update".l10n())) })
            .flatMapLatest { result in
                switch result {
                case let .success(profile):
                    successProperty.onNext(profile)
                case let .fail(status, _):
                    failedProperty.onNext(Alert(title: "update_failed".l10n(), message: status.message))
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "update_failed".l10n()))
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "update_failed".l10n(), message: "update_error_message".l10n(), error: error))
                }
                
                return .empty()
        }
    }
}

