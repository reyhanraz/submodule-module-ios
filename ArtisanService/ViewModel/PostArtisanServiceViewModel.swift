//
//  PostArtisanServiceViewModel.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 24/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Domain
import L10n_swift
import Platform

public struct PostArtisanServiceViewModel<T: ResponseType>: PostArtisanServiceViewModelType, PostArtisanServiceViewModelOutput {
    public typealias Outputs = PostArtisanServiceViewModel<T>
    
    public var outputs: Outputs { return self }
    
    // MARK: - Outputs
    public let validatedMedia: Driver<ValidationResult>
    public let validatedCategoryType: Driver<ValidationResult>
    public let validatedServiceFee: Driver<ValidationResult>
    public let validatedNotes: Driver<ValidationResult>
    public let submitEnabled: Driver<Bool>
    
    public let submit: Driver<Void>
    
    public let loading: Driver<Loading>
    public let failed: Driver<(Status.Detail, [DataError]?)>
    public let exception: Driver<Exception>
    public let success: Driver<T>
    public let unauthorized: Driver<Unauthorized>
    public let dismissResponder: Driver<Bool>
    
    public init<U: UseCase>(
        id: Int?,
        title: Driver<String?>,
        media: Driver<URL?>,
        categoryTypeId: Driver<Int?>,
        serviceFee: Driver<Double?>,
        notes: (Driver<String>, Int, Int),
        submitSignal: Signal<()>,
        useCase: U
        ) where U.R == ArtisanServiceRequest, U.T == T, U.E == Error {
        
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
        
        validatedMedia = media.flatMapLatest { value in
            return value != nil || id != nil ? .just(.ok(message: nil)) : .just(.failed(message: ""))
        }
        
        validatedCategoryType = categoryTypeId.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value == 0 {
                return .just(.failed(message: "service_type_is_required".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedServiceFee = serviceFee.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value < 1 {
                return .just(.failed(message: "invalid_service_fee".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedNotes = notes.0.flatMapLatest { value in
            if value.isEmpty {
                return .just(.empty)
            } else if value.count < notes.1 {
                return .just(.failed(message: "notes_is_required".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        submitEnabled = Driver.combineLatest(validatedMedia, validatedCategoryType, validatedServiceFee, validatedNotes) {
            media, type, serviceFee, notes in
            
            media.isValid && type.isValid && serviceFee.isValid && notes.isValid
            
            }.distinctUntilChanged()
        
        let forms = Driver.combineLatest(media, title, categoryTypeId, serviceFee, notes.0) { media, title, categoryTypeId, serviceFee, notes -> ArtisanServiceRequest in
            let cover: ArtisanServiceRequest.Cover?
            
            if let path = media?.lastPathComponent {
                cover = ArtisanServiceRequest.Cover(name: path)
            } else {
                cover = nil
            }
            
            return ArtisanServiceRequest(
                id: id,
                title: title ?? "",
                categoryTypeIds: [categoryTypeId ?? 0],
                description: notes,
                price: serviceFee ?? 0,
                cover: cover)
        }
        
        submit = submitSignal.withLatestFrom(forms)
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "submitting".l10n()))
                dismissResponderProperty.onNext(true)
            })
            .flatMapLatest { request in
                return useCase.execute(request: request).asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "submit".l10n())) })
            .flatMapLatest { result in
                switch result {
                case let .success(register):
                    successProperty.onNext(register)
                case let .fail(status, errors):
                    failedProperty.onNext((status, errors))
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "submit_failed".l10n(), message: "submit_error_message".l10n(), error: error))
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "", message: "", showLogin: false))
                }
                
                return .empty()
        }
    }
}



