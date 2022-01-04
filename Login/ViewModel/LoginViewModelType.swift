//
//  LoginViewModelType.swift
//  Login
//
//  Created by Fandy Gotama on 14/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Common
import RxCocoa
import Platform

public protocol LoginViewModelOutput {
    associatedtype T
    
    var validatedEmail: Driver<ValidationResult> { get }
    var validatedPassword: Driver<ValidationResult> { get }
    var loginEnabled: Driver<Bool> { get }
    var loading: Driver<Loading> { get }
    var login: Driver<Void> { get }
    var success: Driver<T> { get }
    var unauthorized: Driver<Unauthorized> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol LoginViewModelType {
    associatedtype Outputs = LoginViewModelOutput
    
    var outputs: Outputs { get }
}
