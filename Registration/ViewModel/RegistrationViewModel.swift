//
//  RegistrationViewModel.swift
//  Registration
//
//  Created by Fandy Gotama on 12/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Domain
import L10n_swift
import PhoneNumberKit
import Platform

public struct RegistrationViewModel<T: ResponseType>: RegistrationViewModelType, RegistrationViewModelOutput {
    public typealias Outputs = RegistrationViewModel<T>
    
    public var outputs: Outputs { return self }
    
    // MARK: - Outputs
    public let validatedName: Driver<ValidationResult>
    public let validatedEmail: Driver<ValidationResult>
    public let validatedPhone: Driver<ValidationResult>
    public let validatedPassword: Driver<ValidationResult>
    public let validatedPasswordConfirmation: Driver<ValidationResult>
    public let validatedAgreement: Driver<ValidationResult>

    public let registerEnabled: Driver<Bool>
    
    public let register: Driver<Void>
    
    public let loading: Driver<Loading>
    public let failed: Driver<(Status.Detail, [DataError]?)>
    public let exception: Driver<Exception>
    public let success: Driver<T>
    
    public let dismissResponder: Driver<Bool>
    
    public init<U: UseCase>(
        phone: (Driver<String>, String),
        name: (Driver<String>, Int, Int),
        email: Driver<String>,
        password: Driver<String>,
        gender: Driver<Int>,
        passwordConfirmation: Driver<String>,
        agreement: Driver<Bool?>,
        registerSignal: Signal<()>,
        useCase: U
        ) where U.R == RegisterRequest, U.T == T, U.E == Error {
        
        let phoneNumberKit = PhoneNumberKit()
        
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<T>()
        let failedProperty = PublishSubject<(Status.Detail, [DataError]?)>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        dismissResponder = dismissResponderProperty.asDriver(onErrorJustReturn: false)
        
        validatedName = name.0.flatMapLatest { value in
            if value.isEmpty {
                return .just(.empty)
            } else if value.count < name.1 || value.count > name.2 {
                return .just(.failed(message: "invalid_name_length".l10n()))
            } else if !value.alphabetAndSpace {
                return .just(.failed(message: "invalid_name_characters".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
    
        validatedEmail = email.flatMapLatest { email in
            if email.isEmpty {
                return .just(.empty)
            } else if email.isValidEmail {
                return .just(.ok(message: nil))
            } else {
                return .just(.failed(message: "invalid_email".l10n()))
            }
        }
        
        validatedPhone = phone.0.flatMapLatest { value in
            do {
                let _ = try phoneNumberKit.parse(value, withRegion: phone.1)
                
                return .just(.ok(message: nil))
            } catch {
                if value.isEmpty {
                    return .just(.empty)
                } else {
                    return .just(.failed(message: "invalid_phone".l10n()))
                }
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
        
        validatedPasswordConfirmation = Driver.combineLatest(password, passwordConfirmation) { password, confirmation in
            if confirmation.isEmpty {
                return .empty
            } else if password != confirmation {
                return .failed(message: "invalid_confirmation".l10n())
            } else {
                return .ok(message: nil)
            }
        }

        validatedAgreement = agreement.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }

            if !value {
                return .just(.failed(message: ""))
            } else {
                return .just(.ok(message: nil))
            }
        }

        registerEnabled = Driver.combineLatest(validatedName, validatedEmail, validatedPhone, validatedPassword, validatedPasswordConfirmation, validatedAgreement) {
            name, email, phone, password, passwordConfirmation, agreement in
            
            name.isValid && email.isValid && phone.isValid && password.isValid && passwordConfirmation.isValid && agreement.isValid
            
            }.distinctUntilChanged()
        
        let forms = Driver.combineLatest(phone.0, name.0, gender, email, password) { mobilePhone, name, gender, email, password -> RegisterRequest in
            let phoneNumber = try? phoneNumberKit.parse(mobilePhone, withRegion: phone.1)
            
            let formattedPhone: String
            
            if let phoneNumber = phoneNumber {
                formattedPhone = phoneNumberKit.format(phoneNumber, toType: .e164)
            } else {
                formattedPhone = ""
            }
            
            return RegisterRequest(name: name, email: email, password: password, phone: formattedPhone, gender: gender == 0 ? .male : .female)
        }
        
        register = registerSignal.withLatestFrom(forms)
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "registering".l10n()))
                dismissResponderProperty.onNext(true)
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
}

