//
//  PostCustomizeRequestViewModel.swift
//  Booking
//
//  Created by Fandy Gotama on 15/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common
import Domain

public struct PostCustomizeRequestViewModel<T>: PostCustomizeRequestViewModelType, PostCustomizeRequestViewModelInput, PostCustomizeRequestViewModelOutput {
    public typealias Inputs = PostCustomizeRequestViewModelInput
    public typealias Outputs = PostCustomizeRequestViewModel<T>
    
    public var inputs: Inputs { return self }
    public var outputs: Outputs { return self }
    
    // MARK: - Outputs
    public let validatedAddressName: Driver<ValidationResult>
    public let validatedAddressDetail: Driver<ValidationResult>
    public let validatedLocation: Driver<ValidationResult>
    public let validatedCoordinates: Driver<ValidationResult>
    
    public let postEnabled: Driver<Bool>
    
    public let loading: Driver<Loading>
    public let post: Driver<Void>
    public let success: Driver<T>
    public let failed: Driver<(Status.Detail, [DataError]?)>
    public let unauthorized: Driver<Unauthorized>
    public let exception: Driver<Exception>
    public let dismissResponder: Driver<Bool>
    
    private let _submitProperty = PublishSubject<Void>()
    
    public init<U: UseCase>(
        eventDetail: EventDetail,
        addressId: Driver<Int?>,
        addressName: (Driver<String?>, Int, Int),
        addressDetail: Driver<String>,
        areaId: Driver<Int?>,
        coordinates: Driver<(lat: Double, lon: Double)?>, useCase: U) where U.R == PostCustomRequest, U.T == T, U.E == Error {
        
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
        
        validatedAddressName = addressName.0.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value.isEmpty {
                return .just(.empty)
            } else if value.count < addressName.1 || value.count > addressName.2 {
                return .just(.failed(message: "invalid_name_length".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedAddressDetail = addressDetail.flatMapLatest { detail in
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
        
        postEnabled = Driver.combineLatest(validatedAddressName, validatedAddressDetail, validatedLocation, validatedCoordinates) {
            name, detail, location, coordinates in
            
            name.isValid && detail.isValid && location.isValid && coordinates.isValid
            
            }.distinctUntilChanged()
        
        let forms = Driver.combineLatest(addressId, addressName.0, addressDetail, areaId, coordinates) { addressId, addressName, addressDetail, location, coordinates -> PostCustomRequest in
            
            let service = PostCustomRequest.ServiceRequest(
                categoryTypeId: eventDetail.serviceType,
                quantity: eventDetail.quantity,
                price: eventDetail.serviceFee)
            
            return PostCustomRequest(
                id: eventDetail.id,
                addressId: addressId,
                addressName: addressName,
                addressDetail: addressDetail,
                areaId: location,
                lat: coordinates?.lat,
                lon: coordinates?.lon,
                eventName: eventDetail.name,
                start: eventDetail.date.toUTC,
                note: eventDetail.notes,
                bookingServiceRequests: [service])
        }
        
        post = _submitProperty.asDriver(onErrorJustReturn: ()).withLatestFrom(forms)
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
    
    public func submit() {
        _submitProperty.onNext(())
    }
    
    public init<U: UseCase>(
        eventDetail: EventDetail,
        addressName: Driver<String?>,
        addressDetail: Driver<String?>,
        coordinates: Driver<(lat: Double, lon: Double, address: String)?>,
        useCase: U)
        where U.R == PostCustomRequest, U.T == T, U.E == Error {
        
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
        
        validatedAddressName = PublishSubject<ValidationResult>().asDriver(onErrorDriveWith: .empty())
        validatedAddressDetail = PublishSubject<ValidationResult>().asDriver(onErrorDriveWith: .empty())
        validatedCoordinates = PublishSubject<ValidationResult>().asDriver(onErrorDriveWith: .empty())
        validatedLocation = PublishSubject<ValidationResult>().asDriver(onErrorDriveWith: .empty())
        postEnabled = PublishSubject<Bool>().asDriver(onErrorDriveWith: .empty())
        
        let forms = Driver.combineLatest(addressName, addressDetail, coordinates) {addressName, addressDetail, coordinates -> PostCustomRequest in
            
            let service = PostCustomRequest.ServiceRequest(
                categoryTypeId: eventDetail.serviceType,
                quantity: eventDetail.quantity,
                price: eventDetail.serviceFee)
            return PostCustomRequest(id: eventDetail.id,
                                     eventName: eventDetail.name,
                                     eventNote: eventDetail.notes,
                                     start: eventDetail.date.toUTC,
                                     bookingServiceRequests: [service],
                                     venueName: addressName,
                                     latitude: coordinates?.lat,
                                     longitude: coordinates?.lon,
                                     address: coordinates?.address,
                                     venueNote: addressDetail,
                                     rawAddress: nil)
        }
        
        post = _submitProperty.asDriver(onErrorJustReturn: ()).withLatestFrom(forms)
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





