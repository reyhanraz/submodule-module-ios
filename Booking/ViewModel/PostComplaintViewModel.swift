//
//  PostComplaintViewModel.swift
//  Booking
//
//  Created by Fandy Gotama on 11/01/21.
//  Copyright © 2021 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Domain
import L10n_swift
import Platform
import ServiceWrapper

public struct PostComplaintViewModel<T: ResponseType>: PostComplaintViewModelType, PostComplaintViewModelOutput {
    public typealias Outputs = PostComplaintViewModel<T>
    
    public var outputs: Outputs { return self }
    
    // MARK: - Outputs
    public let validatedReason: Driver<ValidationResult>
    public let sendEnabled: Driver<Bool>
    public let failed: Driver<Alert>
    
    public let send: Driver<Void>
    
    public let loading: Driver<Loading>
    public var exception: Driver<Exception>
    public let success: Driver<T>
    
    public let dismissResponder: Driver<Bool>
    private let _submitProperty = PublishSubject<Void>()
    
    public init<U: UseCase>(
        bookingId: Int,
        reason: (Driver<String>, Int, Int),
        useCase: U) where U.R == PostComplaintRequest, U.T == T, U.E == Error {
        
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<T>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        let failedProperty = PublishSubject<Alert>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        dismissResponder = dismissResponderProperty.asDriver(onErrorJustReturn: false)
        
        validatedReason = reason.0.flatMapLatest { value in
            if value.isEmpty {
                return .just(.ok(message: nil))
            } else if value.count < reason.1 || value.count > reason.2 {
                return .just(.failed(message: "invalid_reason_length".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        sendEnabled = validatedReason.map { $0.isValid }.distinctUntilChanged()
        
            send = _submitProperty.asDriver(onErrorDriveWith: .empty()).withLatestFrom(reason.0)
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "sending".l10n()))
                dismissResponderProperty.onNext(false)
            })
            .flatMapLatest { reason in
                return useCase.execute(request: PostComplaintRequest(bookingId: bookingId, complaint: reason)).asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "sending".l10n())) })
            .flatMapLatest { result in
                switch result {
                case let .success(status):
                    successProperty.onNext(status)
                case let .fail(status, _):
                    failedProperty.onNext(Alert(title: "send_complaint_failed".l10n(), message: status.message))
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "send_complaint_failed".l10n(), message: "send_complaint_error_message".l10n(), error: error))
                default:
                    return .empty()
                }
                
                return .empty()
        }
    }
    
    public func submit(){
        _submitProperty.onNext(())
    }
}

