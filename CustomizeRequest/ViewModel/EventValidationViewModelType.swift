//
//  EventValidationViewModelType.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 03/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common

public protocol EventValidationViewModelInput {
    func serviceTypeApplied(type: Int?)
}

public protocol EventValidationViewModelOutput {
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
}

public protocol EventValidationViewModelType {
    var inputs: EventValidationViewModelInput { get }
    var outputs: EventValidationViewModelOutput { get }
}
