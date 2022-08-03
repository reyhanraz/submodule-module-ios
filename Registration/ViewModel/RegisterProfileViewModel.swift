//
//  RegisterProfileViewModel.swift
//  Registration
//
//  Created by Reyhan Rifqi Azzami on 17/02/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Platform
import PhoneNumberKit
import Domain
import ServiceWrapper

public protocol RegisterProfileViewModelOutput {
    var validatedName: Driver<ValidationResult> { get }
    var validatedEmail: Driver<ValidationResult> { get }
    var validatedPhone: Driver<ValidationResult> { get }
    var validatedPassword: Driver<ValidationResult> { get }
    var validatedPasswordConfirmation: Driver<ValidationResult> { get }
    var nextEnabled: Driver<Bool> { get }
    var result: Driver<(ServiceWrapper.RegisterRequest, String)> { get }
}

protocol RegisterProfileViewModelType {
    var outputs: RegisterProfileViewModelOutput { get }
}

public struct RegisterProfileViewModel: RegisterProfileViewModelType, RegisterProfileViewModelOutput {

    public var outputs: RegisterProfileViewModelOutput { return self }
    
    public let validatedName: Driver<ValidationResult>
    public let validatedEmail: Driver<ValidationResult>
    public let validatedPhone: Driver<ValidationResult>
    public let validatedPassword: Driver<ValidationResult>
    public let validatedPasswordConfirmation: Driver<ValidationResult>
    public let nextEnabled: Driver<Bool>
    public let result: Driver<(ServiceWrapper.RegisterRequest, String)>
    
    public let validatedGender = PublishSubject<ValidationResult>()
    
    public init<U: UseCase>(
        name: (Driver<String>, Int, Int),
        phone: (Driver<String>, String),
        email: Driver<String>,
        gender: Driver<String>,
        password: Driver<String>,
        passwordConfirmation: Driver<String>,
        btnNext: Signal<()>,
        useCase: U) where U.R == CheckUserRequest, U.T == CheckUser, U.E == Error {
        
        let phoneNumberKit = PhoneNumberKit()
        
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
        
        validatedEmail = email.debounce(.milliseconds(500))
                .flatMap { email in
                    return useCase.execute(request: CheckUserRequest(identifier: email, type: .customer, findType: .email)).map { (email, $0) }.asDriver(onErrorDriveWith: .empty())
                }
                .flatMap { result in
                    if result.0.isEmpty {
                        return .just(.empty)
                    }
                    
                    guard result.0.isValidEmail else { return .just(.failed(message: "invalid_email".l10n())) }
                    
                    switch result.1 {
                    case .success:
                        return .just(.failed(message: "email_already_used".l10n()))
                    case let .fail(status, _):
                        if status.code == 400 {
                            return .just(.failed(message: "invalid_email".l10n()))
                        } else if status.code == 404 {
                           return .just(.ok(message: nil))
                        }

                        return .just(.ok(message: nil))
                    default:
                        return .just(.ok(message: nil))
                    }
                }
        
        validatedPhone = phone.0.debounce(.milliseconds(500))
                .flatMap { mobilePhone -> Driver<(String, Result<CheckUser, Error>, String)> in
                    let phoneNumber = try? phoneNumberKit.parse(mobilePhone, withRegion: phone.1)

                    let formattedPhone: String

                    if let phoneNumber = phoneNumber {
                        formattedPhone = phoneNumberKit.format(phoneNumber, toType: .e164)
                    } else {
                        formattedPhone = ""
                    }
                    return useCase.execute(request: CheckUserRequest(identifier: formattedPhone, type: .customer, findType: .phoneNumber)).map { (formattedPhone, $0, mobilePhone) }.asDriver(onErrorDriveWith: .empty())
                }
                .flatMap { result in
                    if result.2.isEmpty{
                        return .just(.empty)
                    }
                    guard let _ = try? phoneNumberKit.parse(result.2, withRegion: phone.1) else {
                        return .just(.failed(message: "invalid_phone".l10n()))
                    }
                    
                    switch result.1 {
                    case .success:
                        return .just(.failed(message: "phone_already_used".l10n()))
                    case let .fail(status, _):
                        if status.code == 400 {
                            return .just(.failed(message: "invalid_phone".l10n()))
                        } else if status.code == 404 {
                            return .just(.ok(message: nil))
                        }

                        return .just(.ok(message: nil))
                    default:
                        return .just(.ok(message: nil))
                    }
                }

            
        let validatedGender: Driver<ValidationResult> = gender.flatMapLatest{ value in
            if value.isEmpty{
                return .just(.empty)
            }else{
                return .just(.ok(message: nil))
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
        
        nextEnabled = Driver.combineLatest(validatedName, validatedEmail, validatedPhone, validatedPassword, validatedPasswordConfirmation, validatedGender) {
            name, email, phone, password, passwordConfirmation, gender in
            
            name.isValid && email.isValid && phone.isValid && password.isValid && passwordConfirmation.isValid && gender.isValid
            
            }.distinctUntilChanged()
        
            let forms = Driver.combineLatest(phone.0, name.0, email, password, gender) { mobilePhone, name, email, password, gender -> (ServiceWrapper.RegisterRequest, String) in
            let phoneNumber = try? phoneNumberKit.parse(mobilePhone, withRegion: phone.1)
            
            let formattedPhone: String
            
            if let phoneNumber = phoneNumber {
                formattedPhone = phoneNumberKit.format(phoneNumber, toType: .e164)
            } else {
                formattedPhone = ""
            }
            
            return (ServiceWrapper.RegisterRequest(name: name,
                                                   email: email,
                                                   password: password,
                                                   phone: formattedPhone,
                                                   gender: gender == "male".l10n() ? .male : .female),
                    mobilePhone)
        }
            
        result = btnNext.withLatestFrom(forms).asDriver(onErrorDriveWith: .empty())
    }
    
    public func validateGender(gender: NewProfile.Gender?){
        guard gender != nil else {
            validatedGender.onNext(.failed(message: "invalid_gender".l10n()))
            return
        }
        validatedGender.onNext(.ok(message: nil))
    }
}
