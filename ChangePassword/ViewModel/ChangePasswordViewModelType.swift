//
//  ChangePasswordViewModelType.swift
//  ChangePassword
//
//  Created by Fandy Gotama on 21/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common

public protocol ChangePasswordViewModelOutput {
    associatedtype T
    
    var validatedCurrentPassword: Driver<ValidationResult> { get }
    var validatedNewPassword: Driver<ValidationResult> { get }
    var validatedPasswordConfirmation: Driver<ValidationResult> { get }
    
    var changeEnabled: Driver<Bool> { get }
    var loading: Driver<Loading> { get }
    var change: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<Alert> { get }
    var unauthorized: Driver<Unauthorized> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol ChangePasswordViewModelType {
    associatedtype Outputs = ChangePasswordViewModelOutput
    
    var outputs: Outputs { get }
}
