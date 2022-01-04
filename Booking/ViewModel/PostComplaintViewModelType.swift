//
//  PostComplaintViewModelType.swift
//  Booking
//
//  Created by Fandy Gotama on 11/01/21.
//  Copyright © 2021 Adrena Teknologi Indonesia. All rights reserved.
//

import Common
import RxCocoa
import Platform

public protocol PostComplaintViewModelOutput {
    associatedtype T
    
    var validatedReason: Driver<ValidationResult> { get }
    var sendEnabled: Driver<Bool> { get }
    var loading: Driver<Loading> { get }
    var send: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<Alert> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol PostComplaintViewModelType {
    associatedtype Outputs = PostComplaintViewModelOutput
    
    var outputs: Outputs { get }
}

