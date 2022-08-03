//
//  EventValidationViewModel.swift
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

public struct EventValidationViewModel<T>: EventValidationViewModelType, EventValidationViewModelOutput, EventValidationViewModelInput {
    public typealias Outputs = EventValidationViewModel<T>
    
    public var inputs: EventValidationViewModelInput { return self }
    public var outputs: Outputs { return self }
    
    public let validatedServiceType: Driver<ValidationResult>
    public let validatedName: Driver<ValidationResult>
    public let validatedDate: Driver<ValidationResult>
    public let validatedServiceFee: Driver<ValidationResult>
    public let validatedQuantity: Driver<ValidationResult>
    public let validatedNotes: Driver<ValidationResult>
    
    public let nextEnabled: Driver<Bool>
    
    public let totalServiceFee: Driver<Double?>
    public let eventDate: Driver<String>
    public let eventDetail: Driver<EventDetail>
    public let updateVenueEnabled: Driver<Bool>
    
    public let loading: Driver<Loading>
    public let post: Driver<Void>
    public let success: Driver<T>
    public let failed: Driver<(Status.Detail, [DataError]?)>
    public let unauthorized: Driver<Unauthorized>
    public let exception: Driver<Exception>
    public let dismissResponder: Driver<Bool>
    
    public let _addressProperty = PublishSubject<Address>()
    private let _updateProperty = PublishSubject<Void>()
    
    public init<U: UseCase>(
        id: Int?,
        serviceType: Driver<Int?>,
        name: (Driver<String?>, Int, Int),
        date: Driver<String?>,
        datePicker: Driver<Date>,
        datePickerDone: Signal<()>,
        serviceFee: Driver<Double?>,
        quantity: Driver<String?>,
        notes: (Driver<String>, Int, Int),
        nextButton: Signal<()>,
        updateVenueButton: Signal<()>, useCase: U) where U.R == PostCustomRequest, U.T == T, U.E == Error {
        
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
        
        validatedServiceType = serviceType.startWith(nil).asDriver(onErrorJustReturn: nil).flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value == 0 {
                return .just(.failed(message: "service_type_is_required".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedName = name.0.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value.isEmpty {
                return .just(.empty)
            } else if value.count < name.1 || value.count > name.2 {
                return .just(.failed(message: "invalid_name_length".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        eventDate = Driver.combineLatest(datePicker.asDriver(), datePickerDone.startWith(())
            .asDriver(onErrorJustReturn: ()))
            .flatMapLatest { (date, _) -> Driver<String> in
                return .just(date.toFullDate)
        }
        
        totalServiceFee = Driver.combineLatest(serviceFee.asDriver(), quantity.asDriver())
            .asDriver(onErrorDriveWith: .empty())
            .flatMapLatest({ (serviceFee, quantity) in
                if let serviceFee = serviceFee, let quantity = quantity, let pax = Int(quantity) {
                    return .just(serviceFee * Double(pax))
                } else {
                    return .empty()
                }
            })
        
        validatedDate = date.flatMapLatest({ date in
            guard let date = date else { return .just(.empty) }
            
            if date.isEmpty {
                return .just(.empty)
            } else {
                if let date = date.toDate(format: "config.date.full_date".l10n()), date.year >= 1900 {
                    return .just(.ok(message: nil))
                } else {
                    return .just(.failed(message: "invalid_event_date".l10n()))
                }
            }
        })
        
        validatedServiceFee = serviceFee.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value < 1 {
                return .just(.failed(message: "invalid_service_fee".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedQuantity = quantity.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value.isEmpty {
                return .just(.empty)
            } else if let quantity = Int(value), quantity > 0 {
                return .just(.ok(message: nil))
            } else {
                return .just(.failed(message: "invalid_quantity".l10n()))
            }
        }
        
        validatedNotes = notes.0.flatMapLatest { value in
            if value.isEmpty {
                return .just(.empty)
            } else if value.trimmingCharacters(in: .whitespacesAndNewlines).count < notes.1 || value.trimmingCharacters(in: .whitespacesAndNewlines).count > notes.2 {
                return .just(.failed(message: "invalid_notes_length".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        nextEnabled = Driver.combineLatest(validatedServiceType, validatedName, validatedDate, validatedServiceFee, validatedQuantity, validatedNotes) {
            serviceType, name, date, serviceFee, quantity, notes in
            
            return serviceType.isValid && name.isValid && date.isValid && serviceFee.isValid && quantity.isValid && notes.isValid
            
            }.distinctUntilChanged()
        
        updateVenueEnabled = nextEnabled
        
        let forms = Driver.combineLatest(serviceType, name.0, datePicker, serviceFee, quantity, notes.0) {
            serviceType, name, date, serviceFee, quantity, note -> EventDetail in
            
            let pax: Int
            
            if let quantity = quantity, let value = Int(quantity) {
                pax = value
            } else {
                pax = 0
            }
            
            return EventDetail(id: id,
                               serviceType: serviceType ?? 0,
                               name: name ?? "",
                               date: date,
                               serviceFee: serviceFee ?? 0,
                               quantity: pax,
                               notes: note)
        }
        
        if id != nil {
            eventDetail = updateVenueButton.withLatestFrom(forms).asDriver(onErrorDriveWith: .empty())
        } else {
            eventDetail = Signal.merge(nextButton, updateVenueButton).withLatestFrom(forms).asDriver(onErrorDriveWith: .empty())
        }
        
        let updateForms = Driver.combineLatest(serviceType, name.0, datePicker, serviceFee, quantity, notes.0, _addressProperty.asDriver(onErrorDriveWith: .empty())) {
            serviceType, name, date, serviceFee, quantity, note, address -> PostCustomRequest in
            
            let pax: Int
            
            if let quantity = quantity, let value = Int(quantity) {
                pax = value
            } else {
                pax = 0
            }
            
            let service = PostCustomRequest.ServiceRequest(
                categoryTypeId: serviceType ?? 0,
                quantity: pax,
                price: serviceFee ?? 0)
            return PostCustomRequest(id: id,
                                     eventName: name ?? "",
                                     eventNote: note,
                                     start: date.toUTC,
                                     bookingServiceRequests: [service],
                                     venueName: address.name,
                                     latitude: address.latitude,
                                     longitude: address.longitude,
                                     address: address.notes,
                                     venueNote: address.notes,
                                     rawAddress: nil)
        }
        
        post = nextButton.withLatestFrom(updateForms)
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "saving".l10n()))
                dismissResponderProperty.onNext(true)
            })
            .flatMapLatest { request in
                useCase.execute(request: request).asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "save".l10n())) })
            .flatMapLatest { result in
                switch result {
                case let .success(register):
                    successProperty.onNext(register)
                case let .fail(status, errors):
                    failedProperty.onNext((status, errors))
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "save_failed".l10n(), message: "save_error_message".l10n(), error: error))
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "", message: "", showLogin: false))
                }
                
                return .empty()
        }
    }
    
    public init<U: UseCase>(
        id: Int?,
        serviceType: Driver<Int?>,
        name: (Driver<String?>, Int, Int),
        date: Driver<String?>,
        datePicker: Driver<Date>,
        datePickerDone: Signal<()>,
        serviceFee: Driver<Double?>,
        quantity: Driver<String?>,
        notes: (Driver<String>, Int, Int),
        nextButton: Signal<()>,
        useCase: U) where U.R == PostCustomRequest, U.T == T, U.E == Error {
        
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
        
        validatedServiceType = serviceType.startWith(nil).asDriver(onErrorJustReturn: nil).flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value == 0 {
                return .just(.failed(message: "service_type_is_required".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedName = name.0.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value.isEmpty {
                return .just(.empty)
            } else if value.count < name.1 || value.count > name.2 {
                return .just(.failed(message: "invalid_name_length".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        eventDate = Driver.combineLatest(datePicker.asDriver(), datePickerDone.startWith(())
            .asDriver(onErrorJustReturn: ()))
            .flatMapLatest { (date, _) -> Driver<String> in
                return .just(date.toFullDate)
        }
        
        totalServiceFee = Driver.combineLatest(serviceFee.asDriver(), quantity.asDriver())
            .asDriver(onErrorDriveWith: .empty())
            .flatMapLatest({ (serviceFee, quantity) in
                if let serviceFee = serviceFee, let quantity = quantity, let pax = Int(quantity) {
                    return .just(serviceFee * Double(pax))
                } else {
                    return .empty()
                }
            })
        
        validatedDate = date.flatMapLatest({ date in
            guard let date = date else { return .just(.empty) }
            
            if date.isEmpty {
                return .just(.empty)
            } else {
                if let date = date.toDate(format: "config.date.full_date".l10n()), date.year >= 1900 {
                    return .just(.ok(message: nil))
                } else {
                    return .just(.failed(message: "invalid_event_date".l10n()))
                }
            }
        })
        
        validatedServiceFee = serviceFee.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value < 1 {
                return .just(.failed(message: "invalid_service_fee".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedQuantity = quantity.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value.isEmpty {
                return .just(.empty)
            } else if let quantity = Int(value), quantity > 0 {
                return .just(.ok(message: nil))
            } else {
                return .just(.failed(message: "invalid_quantity".l10n()))
            }
        }
        
        validatedNotes = notes.0.flatMapLatest { value in
            if value.isEmpty {
                return .just(.empty)
            } else if value.trimmingCharacters(in: .whitespacesAndNewlines).count < notes.1 || value.trimmingCharacters(in: .whitespacesAndNewlines).count > notes.2 {
                return .just(.failed(message: "invalid_notes_length".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        nextEnabled = Driver.combineLatest(validatedServiceType, validatedName, validatedDate, validatedServiceFee, validatedQuantity, validatedNotes) {
            serviceType, name, date, serviceFee, quantity, notes in
            
            return serviceType.isValid && name.isValid && date.isValid && serviceFee.isValid && quantity.isValid && notes.isValid
            
            }.distinctUntilChanged()
        
        updateVenueEnabled = nextEnabled
        
        let forms = Driver.combineLatest(serviceType, name.0, datePicker, serviceFee, quantity, notes.0) {
            serviceType, name, date, serviceFee, quantity, note -> EventDetail in
            
            let pax: Int
            
            if let quantity = quantity, let value = Int(quantity) {
                pax = value
            } else {
                pax = 0
            }
            
            return EventDetail(id: id,
                               serviceType: serviceType ?? 0,
                               name: name ?? "",
                               date: date,
                               serviceFee: serviceFee ?? 0,
                               quantity: pax,
                               notes: note)
        }
        
        if id != nil {
            eventDetail = _updateProperty.withLatestFrom(forms).asDriver(onErrorDriveWith: .empty())
        } else {
            eventDetail = Signal.merge(nextButton).withLatestFrom(forms).asDriver(onErrorDriveWith: .empty())
        }
        
        let updateForms = Driver.combineLatest(serviceType, name.0, datePicker, serviceFee, quantity, notes.0, _addressProperty.asDriver(onErrorDriveWith: .empty())) {
            serviceType, name, date, serviceFee, quantity, note, address -> PostCustomRequest in
            
            let pax: Int
            
            if let quantity = quantity, let value = Int(quantity) {
                pax = value
            } else {
                pax = 0
            }
            
            let service = PostCustomRequest.ServiceRequest(
                categoryTypeId: serviceType ?? 0,
                quantity: pax,
                price: serviceFee ?? 0)
            
            return PostCustomRequest(id: id,
                                     eventName: name ?? "",
                                     eventNote: note,
                                     start: date.toUTC,
                                     bookingServiceRequests: [service],
                                     venueName: address.name,
                                     latitude: address.latitude,
                                     longitude: address.longitude,
                                     address: address.address,
                                     venueNote: address.notes,
                                     rawAddress: nil)
        }
        
        post = nextButton.withLatestFrom(updateForms)
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "saving".l10n()))
                dismissResponderProperty.onNext(true)
            })
            .flatMapLatest { request in
                useCase.execute(request: request).asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "save".l10n())) })
            .flatMapLatest { result in
                switch result {
                case let .success(register):
                    successProperty.onNext(register)
                case let .fail(status, errors):
                    failedProperty.onNext((status, errors))
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "save_failed".l10n(), message: "save_error_message".l10n(), error: error))
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "", message: "", showLogin: false))
                }
                
                return .empty()
        }
    }
    
    public func addressLoaded(address: Address) {
        _addressProperty.onNext(address)
    }
}




