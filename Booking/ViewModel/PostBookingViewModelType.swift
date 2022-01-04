//
//  PostBookingViewModelType.swift
//  Booking
//
//  Created by Fandy Gotama on 29/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common

public protocol PostBookingViewModelInput {
    func submit()
}

public protocol PostBookingViewModelOutput {
    associatedtype T
    
    var validatedAddressName: Driver<ValidationResult> { get }
    var validatedAddressDetail: Driver<ValidationResult> { get }
    var validatedLocation: Driver<ValidationResult> { get }
    var validatedCoordinates: Driver<ValidationResult> { get }
    
    var postEnabled: Driver<Bool> { get }
    var loading: Driver<Loading> { get }
    var post: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<(Status.Detail, [DataError]?)> { get }
    var unauthorized: Driver<Unauthorized> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol PostBookingViewModelType {
    associatedtype Inputs = PostBookingViewModelInput
    associatedtype Outputs = PostBookingViewModelOutput
    
    var inputs: Inputs { get }
    var outputs: Outputs { get }
}
