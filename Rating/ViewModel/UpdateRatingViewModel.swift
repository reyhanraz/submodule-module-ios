//
//  UpdateRatingViewModel.swift
//  Rating
//
//  Created by Fandy Gotama on 01/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Domain
import L10n_swift
import Platform
import ServiceWrapper

public struct UpdateRatingViewModel<T: ResponseType>: UpdateRatingViewModelType, UpdateRatingViewModelInput, UpdateRatingViewModelOutput {
    public typealias Outputs = UpdateRatingViewModel<T>
    
    public var inputs: UpdateRatingViewModelInput { return self }
    public var outputs: Outputs { return self }
    
    // MARK: - Outputs
    public let validatedRating: Driver<ValidationResult>
    public let validatedComment: Driver<ValidationResult>
    public let updateEnabled: Driver<Bool>
    
    public let update: Driver<Void>
    
    public let loading: Driver<Loading>
    public let failed: Driver<(Status.Detail, [DataError]?)>
    public let exception: Driver<Exception>
    public let success: Driver<T>
    public let unauthorized: Driver<Unauthorized>
    public let dismissResponder: Driver<Bool>
    
    private let _ratingProperty = PublishSubject<Double>()
    private let _submitProperty = PublishSubject<Void>()
    
    public init<U: UseCase>(
        id: Int,
        comment: Driver<String>,
        useCase: U
        ) where U.R == RatingRequest, U.T == T, U.E == Error {
        
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<T>()
        let failedProperty = PublishSubject<(Status.Detail, [DataError]?)>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        dismissResponder = dismissResponderProperty.asDriver(onErrorJustReturn: false)
        
        validatedRating = _ratingProperty.asDriver(onErrorJustReturn: 0).startWith(0).flatMapLatest { value in
            
            if value == 0 {
                return .just(.empty)
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedComment = comment.flatMapLatest { comment in
            if comment.isEmpty{
                return .just(.ok(message: nil))
            }else if comment.count > 255 || comment.count < 15 {
                return .just(.failed(message: "review_comment_is_required".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        updateEnabled = Driver.combineLatest(validatedRating, validatedComment) {
            rating, comment in
            
            rating.isValid && comment.isValid
            
            }.distinctUntilChanged()
        
        let forms = Driver.combineLatest(_ratingProperty.asDriver(onErrorJustReturn: 0), comment) { rating, comment in
            RatingRequest(bookingId: id, rating: Int(rating), comment: comment.isEmpty ? nil : comment)
        }
        
        update = _submitProperty.asDriver(onErrorJustReturn: ()).withLatestFrom(forms)
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "sending".l10n()))
                dismissResponderProperty.onNext(true)
            })
            .flatMapLatest { request in
                return useCase.execute(request: request).asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "send".l10n())) })
            .flatMapLatest { result in
                switch result {
                case let .success(register):
                    successProperty.onNext(register)
                case let .fail(status, errors):
                    failedProperty.onNext((status, errors))
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "send_failed".l10n(), message: "send_review_error_message".l10n(), error: error))
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "", message: "", showLogin: false))
                }
                
                return .empty()
        }
    }
    
    public func ratingUpdated(rating: Double) {
        _ratingProperty.onNext(rating)
    }
    
    public func submit() {
        _submitProperty.onNext(())
    }
}



