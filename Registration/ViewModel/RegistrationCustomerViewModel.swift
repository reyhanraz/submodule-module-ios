//
//  RegistrationCustomerViewModel.swift
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
    var result: Driver<(RegisterRequest, String)> { get }
}

protocol RegisterProfileViewModelType {
    var outputs: RegisterProfileViewModelOutput { get }
}

public struct RegisterCustomerViewModel: RegisterProfileViewModelType, RegisterProfileViewModelOutput {

    public var outputs: RegisterProfileViewModelOutput { return self }
    
    public let validatedName: Driver<ValidationResult>
    public let validatedEmail: Driver<ValidationResult>
    public let validatedPhone: Driver<ValidationResult>
    public let validatedPassword: Driver<ValidationResult>
    public let validatedPasswordConfirmation: Driver<ValidationResult>
    public let nextEnabled: Driver<Bool>
    public let result: Driver<(RegisterRequest, String)>
    
    public let validatedGender = PublishSubject<ValidationResult>()
    
    public init<U: UseCase>(
        name: (Driver<String>, Int, Int),
        phone: (Driver<String>, String),
        email: Driver<String>,
        gender: Driver<String>,
        password: Driver<String>,
        passwordConfirmation: Driver<String>,
        btnNext: Signal<()>,
        useCase: U) where U.R == CheckUserRequest, U.T == Status, U.E == Error {
        
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
            
            if value.isEmpty {
                return .just(.empty)
            }else if !value.starts(with: "0"){
                return .just(.failed(message: "invalid_phone".l10n()))
            } else {
                do {
                    let _ = try phoneNumberKit.parse(value, withRegion: phone.1)
                    
                    return .just(.ok(message: nil))
                } catch {
                    return .just(.failed(message: "invalid_phone".l10n()))
                }
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
        
        let forms = Driver.combineLatest(phone.0, name.0, email, password, gender) { mobilePhone, name, email, password, gender -> (RegisterRequest, String) in
            let phoneNumber = try? phoneNumberKit.parse(mobilePhone, withRegion: phone.1)
            
            let formattedPhone: String
            
            if let phoneNumber = phoneNumber {
                formattedPhone = phoneNumberKit.format(phoneNumber, toType: .e164)
            } else {
                formattedPhone = ""
            }
            
            return (RegisterRequest(name: name, email: email, password: password, phone: formattedPhone, gender: gender == "male".l10n() ? .male : .female), mobilePhone)
        }
            
        result = btnNext.withLatestFrom(forms).asDriver(onErrorDriveWith: .empty())
    }
    
    public func validateGender(gender: User.Gender?){
        guard gender != nil else {
            validatedGender.onNext(.failed(message: "invalid_gender".l10n()))
            return
        }
        validatedGender.onNext(.ok(message: nil))
    }
}
