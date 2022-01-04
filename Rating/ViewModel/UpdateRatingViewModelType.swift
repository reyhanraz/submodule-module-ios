//
//  UpdateRatingViewModelType.swift
//  Rating
//
//  Created by Fandy Gotama on 01/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common

public protocol UpdateRatingViewModelOutput {
    associatedtype T
    
    var validatedRating: Driver<ValidationResult> { get }
    var validatedComment: Driver<ValidationResult> { get }
    
    var updateEnabled: Driver<Bool> { get }
    var loading: Driver<Loading> { get }
    var update: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<(Status.Detail, [DataError]?)> { get }
    var unauthorized: Driver<Unauthorized> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol UpdateRatingViewModelInput {
    func ratingUpdated(rating: Double)
}

public protocol UpdateRatingViewModelType {
    associatedtype Outputs = UpdateRatingViewModelOutput
    
    var inputs: UpdateRatingViewModelInput { get }
    var outputs: Outputs { get }
}
