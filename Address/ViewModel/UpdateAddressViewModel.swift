//
//  UpdateAddressViewModel.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Common
import Domain
import L10n_swift
import Platform

public struct UpdateAddressViewModel<T: ResponseType>: UpdateAddressViewModelType, UpdateAddressViewModelOutput {
    public typealias Outputs = UpdateAddressViewModel<T>

    public var outputs: Outputs { return self }
    
    // MARK: - Outputs
    public let validatedAddressName: Driver<ValidationResult>
    public let validatedAddressDetail: Driver<ValidationResult>
    public let validatedLocation: Driver<ValidationResult>
    public let validatedCoordinates: Driver<ValidationResult>
    public let updateEnabled: Driver<Bool>
    
    public let update: Driver<Void>
    
    public let loading: Driver<Loading>
    public let failed: Driver<(Status.Detail, [DataError]?)>
    public let exception: Driver<Exception>
    public let success: Driver<T>
    public let unauthorized: Driver<Unauthorized>
    public let dismissResponder: Driver<Bool>
    
    public init<U: UseCase>(
        id: Int?,
        name: (Driver<String?>, Int, Int),
        detail: Driver<String>,
        areaId: Driver<Int?>,
        coordinates: Driver<(lat: Double, lon: Double)?>,
        updateSignal: Signal<()>,
        useCase: U
        ) where U.R == AddressRequest, U.T == T, U.E == Error {
        
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
        
        validatedAddressName = name.0.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value.isEmpty {
                return .just(.empty)
            } else if value.count < name.1 || value.count > name.2 {
                return .just(.failed(message: "invalid_name_length".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedAddressDetail = detail.flatMapLatest { detail in
            if detail.isEmpty {
                return .just(.empty)
            } else if detail.count < 1 {
                return .just(.failed(message: "address_is_required".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedLocation = areaId.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value == 0 {
                return .just(.failed(message: "province_is_required".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedCoordinates = coordinates.flatMapLatest { value in
            if value == nil {
                return .just(.empty)
            }
            
            return .just(.ok(message: nil))
        }
        
        updateEnabled = Driver.combineLatest(validatedAddressName, validatedAddressDetail, validatedLocation, validatedCoordinates) {
            name, detail, location, coordinates in
            
            name.isValid && detail.isValid && location.isValid && coordinates.isValid
            
            }.distinctUntilChanged()
        
        let forms = Driver.combineLatest(name.0, detail, areaId, coordinates) { name, detail, location, coordinates in
            AddressRequest(addressID: id, name: name, note: detail, lat: coordinates?.lat, lon: coordinates?.lon, address: detail, areaId: location)
        }
        
        update = updateSignal.withLatestFrom(forms)
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
    
    public init<U: UseCase>(
        id: Int?,
        name: (Driver<String?>, Int, Int),
        detail: (Driver<String>, Int, Int),
        areaId: Driver<Int?>,
        updateSignal: Signal<()>,
        useCase: U
        ) where U.R == AddressRequest, U.T == T, U.E == Error {
        
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
        
        validatedAddressName = name.0.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value.isEmpty {
                return .just(.empty)
            } else if value.count < name.1 || value.count > name.2 {
                return .just(.failed(message: "invalid_name_length".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedAddressDetail = detail.0.flatMapLatest { value in
            
            if value.isEmpty {
                return .just(.empty)
            } else if value.count < detail.1 || value.count > detail.2{
                return .just(.failed(message: "invalid_address_length".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedLocation = areaId.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value == 0 {
                return .just(.failed(message: "province_is_required".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedCoordinates = PublishSubject<ValidationResult>().asDriver(onErrorDriveWith: .empty())
        
        updateEnabled = Driver.combineLatest(validatedAddressName, validatedAddressDetail, validatedLocation) {
            name, detail, location in
            
            name.isValid && detail.isValid && location.isValid
            
            }.distinctUntilChanged()
        
            let forms = Driver.combineLatest(name.0, detail.0, areaId) { name, detail, location in
            AddressRequest(addressID: id, name: name, note: detail, lat: 0, lon: 0, address: nil, areaId: location)
        }
        
        update = updateSignal.withLatestFrom(forms)
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


