//
//  UpdateIdentityViewModel.swift
//  Profile
//
//  Created by Fandy Gotama on 30/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common
import Domain
import PhoneNumberKit

public struct UpdateIdentityViewModel<T: ResponseType>: UpdateIdentityViewModelType, UpdateIdentityViewModelOutput {
    public typealias Outputs = UpdateIdentityViewModel<T>
    
    public var outputs: Outputs { return self }
    
    public let validatedIdentity: Driver<ValidationResult>
    
    public let updateEnabled: Driver<Bool>
    public let loading: Driver<Loading>
    public let update: Driver<Void>
    public let success: Driver<T>
    public let failed: Driver<Alert>
    public let exception: Driver<Exception>
    public let unauthorized: Driver<Unauthorized>
    public let dismissResponder: Driver<Bool>
    
    public init<U: UseCase>(
        identity: (Driver<String>, Int),
        updateButton: Signal<()>,
        useCase: U) where U.R == IdentityRequest, U.T == T, U.E == Error {
        
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<T>()
        let failedProperty = PublishSubject<Alert>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        dismissResponder = dismissResponderProperty.asDriver(onErrorJustReturn: false)
        
        validatedIdentity = identity.0.flatMapLatest { value in
            if value.isEmpty {
                return .just(.empty)
            } else if value.count == identity.1 {
                return .just(.ok(message: nil))
            } else {
                return .just(.failed(message: "id_number_is_required".l10n()))
            }
        }
        
        updateEnabled = validatedIdentity.map { $0.isValid }.distinctUntilChanged()
        
        let forms = identity.0.map { identity -> IdentityRequest in
            IdentityRequest(identityCardNumber: identity)
        }
        
        update = updateButton.withLatestFrom(forms)
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "updating".l10n()))
                dismissResponderProperty.onNext(true)
            })
            .flatMapLatest { request in
                return useCase.execute(request: request).asDriver(onErrorDriveWith: .empty())
        }
        .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "update".l10n())) })
        .flatMapLatest { result in
            switch result {
            case let .success(profile):
                successProperty.onNext(profile)
            case let .fail(status, _):
                failedProperty.onNext(Alert(title: "update_failed".l10n(), message: status.message))
            case .unauthorized:
                unauthorizedProperty.onNext(Unauthorized(title: "update_failed".l10n()))
            case let .error(error):
                exceptionProperty.onNext(Exception(title: "update_failed".l10n(), message: "update_error_message".l10n(), error: error))
            }
            
            return .empty()
        }
    }
}


