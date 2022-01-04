//
//  RegistrationViewModelType.swift
//  Registration
//
//  Created by Fandy Gotama on 12/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Common
import RxCocoa
import Platform

public protocol RegistrationViewModelOutput {
    associatedtype T
    
    var validatedName: Driver<ValidationResult> { get }
    var validatedEmail: Driver<ValidationResult> { get }
    var validatedPhone: Driver<ValidationResult> { get }
    var validatedPassword: Driver<ValidationResult> { get }
    var validatedPasswordConfirmation: Driver<ValidationResult> { get }
    var validatedAgreement: Driver<ValidationResult> { get }

    var registerEnabled: Driver<Bool> { get }
    var loading: Driver<Loading> { get }
    var register: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<(Status.Detail, [DataError]?)> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol RegistrationViewModelType {
    associatedtype Outputs = RegistrationViewModelOutput
    
    var outputs: Outputs { get }
}
