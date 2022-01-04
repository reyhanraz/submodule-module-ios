//
//  EventValidationViewModelType.swift
//  Booking
//
//  Created by Fandy Gotama on 15/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common

public protocol EventValidationViewModelInput {
    func addressLoaded(address: Address)
}

public protocol EventValidationViewModelOutput {
    associatedtype T
    
    var validatedServiceType: Driver<ValidationResult> { get }
    var validatedName: Driver<ValidationResult> { get }
    var validatedDate: Driver<ValidationResult> { get }
    var validatedServiceFee: Driver<ValidationResult> { get }
    var validatedQuantity: Driver<ValidationResult> { get }
    var validatedNotes: Driver<ValidationResult> { get }
    
    var totalServiceFee: Driver<Double?> { get }
    var eventDate: Driver<String> { get }
    var eventDetail: Driver<EventDetail> { get }
    var nextEnabled: Driver<Bool> { get }
    var updateVenueEnabled: Driver<Bool> { get }
    
    var loading: Driver<Loading> { get }
    var post: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<(Status.Detail, [DataError]?)> { get }
    var unauthorized: Driver<Unauthorized> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol EventValidationViewModelType {
    associatedtype Outputs = EventValidationViewModelOutput
    
    var inputs: EventValidationViewModelInput { get }
    var outputs: Outputs { get }
}

