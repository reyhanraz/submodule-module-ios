//
//  UpdateProfileViewModel.swift
//  Profile
//
//  Created by Fandy Gotama on 20/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common
import Domain
import PhoneNumberKit

public struct UpdateProfileViewModel<T: ResponseType>: UpdateProfileViewModelType, UpdateProfileViewModelOutput {
    public typealias Outputs = UpdateProfileViewModel<T>
    
    public var outputs: Outputs { return self }
    
    public let validatedName: Driver<ValidationResult>
    public let validatedPhone: Driver<ValidationResult>
    public let validatedBirthdate: Driver<ValidationResult>
    public let birthdate: Driver<String>
    public let updateEnabled: Driver<Bool>
    public let loading: Driver<Loading>
    public let update: Driver<Void>
    public let success: Driver<T>
    public let failed: Driver<Alert>
    public let exception: Driver<Exception>
    public let unauthorized: Driver<Unauthorized>
    public let dismissResponder: Driver<Bool>
    
    public init<U: UseCase>(
        id: String,
        phone: (Driver<String?>, String),
        name: (Driver<String?>, Int, Int),
        dob: Driver<String?>,
        datePicker: Driver<Date>,
        datePickerDone: Signal<()>,
        gender: Driver<Int>,
        updateButton: Signal<()>,
        useCase: U) where U.R == ProfileRequest, U.T == T, U.E == Error {
    
        let phoneNumberKit = PhoneNumberKit()
        
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
        
        validatedName = name.0.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            if value.isEmpty {
                return .just(.empty)
            } else if value.count < name.1 || value.count > name.2 {
                return .just(.failed(message: "invalid_name_length".l10n()))
            } else if !value.alphabetAndSpace {
                return .just(.failed(message: "invalid_name_characters".l10n()))
            } else {
                return .just(.ok(message: nil))
            }
        }
        
        validatedPhone = phone.0.flatMapLatest { value in
            guard let value = value else { return .just(.empty) }
            
            do {
                let _ = try phoneNumberKit.parse(value, withRegion: phone.1)
                
                return .just(.ok(message: nil))
            } catch {
                if value.isEmpty {
                    return .just(.empty)
                } else {
                    return .just(.failed(message: "invalid_phone".l10n()))
                }
            }
        }
        
        birthdate = Driver.combineLatest(datePicker.asDriver(), datePickerDone.startWith(())
            .asDriver(onErrorJustReturn: ()))
            .flatMapLatest { (date, _) -> Driver<String> in
                return .just(date.toMediumDate)
        }
        
        validatedBirthdate = dob.flatMapLatest({ birthday in
            guard let birthday = birthday else { return .just(.empty) }
            
            if birthday.isEmpty {
                return .just(.empty)
            } else {
                let today = Date()
                let calendar = Calendar.current
                let minimumAge = Int("config.minimum_age".l10n()) ?? 1
                if let date = birthday.toDate(format: "config.date.medium_date".l10n()), date.year >= 1900 && date.year + minimumAge <= calendar.component(.year, from: today) {
                    return .just(.ok(message: nil))
                } else {
                    return .just(.failed(message: "invalid_date_of_birth".l10n()))
                }
            }
        })
        
        updateEnabled = Driver.combineLatest(validatedName, validatedPhone, validatedBirthdate) {
            name, phone, birthdate in
            
            name.isValid && phone.isValid && birthdate.isValid
        }.distinctUntilChanged()
        
        let forms = Driver.combineLatest(name.0, phone.0, dob, gender) {
            (name, phone, dob, gender) -> ProfileRequest in
            
            ProfileRequest(id: id, name: name ?? "", phone: phone ?? "", dob: dob?.toSystemDate, gender: gender == 0 ? .male : .female)
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
