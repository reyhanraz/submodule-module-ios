//
//  UpdateIdentityViewModelType.swift
//  Profile
//
//  Created by Fandy Gotama on 30/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common

public protocol UpdateIdentityViewModelOutput {
    associatedtype T
    
    var validatedIdentity: Driver<ValidationResult> { get }
    
    var updateEnabled: Driver<Bool> { get }
    var loading: Driver<Loading> { get }
    var update: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<Alert> { get }
    var unauthorized: Driver<Unauthorized> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol UpdateIdentityViewModelType {
    associatedtype Outputs = UpdateIdentityViewModelOutput
    
    var outputs: Outputs { get }
}
