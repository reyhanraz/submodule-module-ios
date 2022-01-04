//
//  UpdateProfileViewModelType.swift
//  Profile
//
//  Created by Fandy Gotama on 20/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common

public protocol UpdateProfileViewModelOutput {
    associatedtype T
    
    var validatedName: Driver<ValidationResult> { get }
    var validatedPhone: Driver<ValidationResult> { get }
    var validatedBirthdate: Driver<ValidationResult> { get }
    
    var birthdate: Driver<String> { get }
    var updateEnabled: Driver<Bool> { get }
    var loading: Driver<Loading> { get }
    var update: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<Alert> { get }
    var unauthorized: Driver<Unauthorized> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol UpdateProfileViewModelType {
    associatedtype Outputs = UpdateProfileViewModelOutput
    
    var outputs: Outputs { get }
}
