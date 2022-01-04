//
//  BookingEventDetailViewModel.swift
//  Booking
//
//  Created by Fandy Gotama on 29/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common
import Domain

public struct BookingEventDetailViewModel: BookingEventDetailViewModelType, BookingEventDetailViewModelOutput {
    
    public var outputs: BookingEventDetailViewModelOutput { return self }
    
    public let validatedName: Driver<ValidationResult>
    public let validatedDate: Driver<ValidationResult>
    public let validatedAvailability: Driver<ValidationResult>
    
    public let nextEnabled: Driver<Bool>
    
    public let eventDate: Driver<String>
    public let eventDetail: Driver<(String, Date)>
    
    public init<U: UseCase>(
        id: Int?,
        artisanId: Int,
        services: [(serviceId: Int, quantity: Int)],
        name: (Driver<String?>, Int, Int),
        date: Driver<String?>,
        datePicker: Driver<Date>,
        datePickerDone: Signal<()>,
        nextButton: Signal<()>,
        useCase: U) where U.R == CheckAvailabilityRequest, U.T == Availability, U.E == Error {
        
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
        
        validatedAvailability = Driver.combineLatest(datePicker.asDriver(onErrorDriveWith: .empty()), date)
            .debounce(.milliseconds(500))
            .flatMapLatest({ (date, dateString) -> Driver<(Date, Result<Availability, Error>)> in
                if dateString?.isEmpty == true {
                    return .empty()
                }
                
                let request = CheckAvailabilityRequest(
                    artisanId: artisanId,
                    timeStart: date.toUTC,
                    serviceRequests: services.map({ CheckAvailabilityRequest.ServiceRequest(serviceId: $0.serviceId, quantity: $0.quantity) }),
                    customRequestServiceRequests: nil)
                
                return useCase.execute(request: request).map { (date, $0) }.asDriver(onErrorDriveWith: .empty())
            }).flatMapLatest({ result in
                switch result.1 {
                    case let .success(data):
                        if data.data?.available == true {
                            return .just(.ok(message: nil))
                        } else {
                            return .just(.failed(message: "artisan_not_available".l10n(args: [result.0.toFullDate])))
                        }
                    default:
                        return .just(.ok(message: nil))
                    
                }
            })
        
        nextEnabled = Driver.combineLatest(validatedName, validatedDate) {
            name, date in
            
            name.isValid && date.isValid
            
            }.distinctUntilChanged()
        
        
        let forms = Driver.combineLatest(name.0, datePicker) { name, date in (name ?? "", date) }
            
        eventDetail = nextButton.withLatestFrom(forms).asDriver(onErrorDriveWith: .empty())
    }
}


