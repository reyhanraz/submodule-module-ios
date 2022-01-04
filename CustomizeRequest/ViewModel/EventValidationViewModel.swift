//
//  EventValidationViewModel.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 03/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common
import Domain

public struct EventValidationViewModel: EventValidationViewModelType, EventValidationViewModelInput, EventValidationViewModelOutput {
    
    public var inputs: EventValidationViewModelInput { return self }
    public var outputs: EventValidationViewModelOutput { return self }
    
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
    
    private let _serviceTypeProperty = PublishSubject<Int?>()
    
    public init(
        id: Int?,
        name: (Driver<String?>, Int, Int),
        date: Driver<String?>,
        datePicker: Driver<Date>,
        datePickerDone: Signal<()>,
        serviceFee: Driver<Double?>,
        quantity: Driver<String?>,
        notes: (Driver<String>, Int, Int),
        nextButton: Signal<()>) {
        
        validatedServiceType = _serviceTypeProperty.startWith(nil).asDriver(onErrorJustReturn: nil).flatMapLatest { value in
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
            } else if value.count < notes.1 || value.count > notes.2 {
                return .just(.failed(message: "invalid_notes_length".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        nextEnabled = Driver.combineLatest(validatedServiceType, validatedName, validatedDate, validatedServiceFee, validatedQuantity, validatedNotes) {
            serviceType, name, date, serviceFee, quantity, notes in
            
            return serviceType.isValid && name.isValid && date.isValid && serviceFee.isValid && quantity.isValid && notes.isValid
            
            }.distinctUntilChanged()
        
        
        let forms = Driver.combineLatest(_serviceTypeProperty.asDriver(onErrorJustReturn: nil), name.0, datePicker, serviceFee, quantity, notes.0) {
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
        
        eventDetail = nextButton.withLatestFrom(forms).asDriver(onErrorDriveWith: .empty())
    }
    
    public func serviceTypeApplied(type: Int?) {
        _serviceTypeProperty.onNext(type)
    }
}



