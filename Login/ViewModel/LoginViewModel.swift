//
//  LoginViewModel.swift
//  Login
//
//  Created by Fandy Gotama on 14/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Domain
import L10n_swift
import Platform

public struct LoginViewModel<T: ResponseType>: LoginViewModelType, LoginViewModelOutput {
    public typealias Outputs = LoginViewModel<T>
    
    public var outputs: Outputs { return self }
    
    // MARK: - Outputs
    public let validatedEmail: Driver<ValidationResult>
    public let validatedPassword: Driver<ValidationResult>
    public let loginEnabled: Driver<Bool>
    
    public let login: Driver<Void>
    
    public let loading: Driver<Loading>
    public var unauthorized: Driver<Unauthorized>
    public let exception: Driver<Exception>
    public let success: Driver<T>
    
    public let dismissResponder: Driver<Bool>
        
    public init<U: UseCase>(
        email: Driver<String>,
        password: Driver<String>,
        loginSignal: Signal<()>,
        useCase: U
        ) where U.R == LoginRequest, U.T == T, U.E == Error {
        
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<T>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
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
        
        validatedPassword = password.flatMapLatest { value in
            if value.isEmpty {
                return .just(.empty)
            } else if !value.validPassword {
                return .just(.failed(message: "invalid_password".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
    
        loginEnabled = Driver.combineLatest(validatedEmail, validatedPassword) {
            email, password in
            
            email.isValid && password.isValid
            
            }.distinctUntilChanged()
        
        let forms = Driver.combineLatest(email, password) { email, password in
            LoginRequest(email: email, password: password)
        }
        
        login = loginSignal.withLatestFrom(forms)
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "logging_in".l10n()))
                dismissResponderProperty.onNext(true)
            })
            .flatMapLatest { request in
                return useCase.execute(request: request).asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "login".l10n())) })
            .flatMapLatest { result in
                switch result {
                case let .success(register):
                    successProperty.onNext(register)
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "login_failed".l10n(), message: "login_error_message".l10n(), error: error))
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "login_failed".l10n(), message: "login_unauthorized".l10n(), showLogin: false))
                default:
                    return .empty()
                }
                
                return .empty()
        }
    }
}

