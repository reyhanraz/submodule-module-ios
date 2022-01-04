//
//  PostArtisanServiceViewModelType.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 24/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common

public protocol PostArtisanServiceViewModelOutput {
    associatedtype T
    
    var validatedMedia: Driver<ValidationResult> { get }
    var validatedCategoryType: Driver<ValidationResult> { get }
    var validatedServiceFee: Driver<ValidationResult> { get }
    var validatedNotes: Driver<ValidationResult> { get }
    
    var submitEnabled: Driver<Bool> { get }
    var loading: Driver<Loading> { get }
    var submit: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<(Status.Detail, [DataError]?)> { get }
    var unauthorized: Driver<Unauthorized> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

public protocol PostArtisanServiceViewModelType {
    associatedtype Outputs = PostArtisanServiceViewModelOutput
    
    var outputs: Outputs { get }
}
