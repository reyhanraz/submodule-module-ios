//
//  UpdateAddressViewModelType.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common

public protocol UpdateAddressViewModelOutput {
    associatedtype T
    
    var validatedAddressName: Driver<ValidationResult> { get }
    var validatedAddressDetail: Driver<ValidationResult> { get }
    var validatedLocation: Driver<ValidationResult> { get }
    var validatedCoordinates: Driver<ValidationResult> { get }
    
    var updateEnabled: Driver<Bool> { get }
    var loading: Driver<Loading> { get }
    var update: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<(Status.Detail, [DataError]?)> { get }
    var unauthorized: Driver<Unauthorized> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol UpdateAddressViewModelType {
    associatedtype Outputs = UpdateAddressViewModelOutput
    
    var outputs: Outputs { get }
}
