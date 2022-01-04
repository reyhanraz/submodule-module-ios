//
//  ForgotPasswordViewModelType.swift
//  ForgotPassword
//
//  Created by Fandy Gotama on 18/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Common
import RxCocoa
import Platform

public protocol ForgotPasswordViewModelOutput {
    associatedtype T
    
    var validatedEmail: Driver<ValidationResult> { get }
    var resetEnabled: Driver<Bool> { get }
    var loading: Driver<Loading> { get }
    var reset: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<Alert> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol ForgotPasswordViewModelType {
    associatedtype Outputs = ForgotPasswordViewModelOutput
    
    var outputs: Outputs { get }
}
