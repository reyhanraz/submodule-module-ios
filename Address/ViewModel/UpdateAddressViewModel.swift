//
//  UpdateAddressViewModel.swift
//  Address
//
//  Created by Reyhan Rifqi Azzami on 27/05/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import RxCocoa
import RxSwift
import Common
import CommonUI
import Domain
import Platform
import ServiceWrapper

public struct UpdateAddressViewModel{
    public typealias Response = Detail<Address>

    public let loading: Driver<Loading>
    public let failed: Driver<Status.Detail>
    public let exception: Driver<Exception>
    public let success: Driver<Response>
    public let unauthorized: Driver<Unauthorized>
    public let dismissResponder: Driver<Bool>
    public let update: Driver<Void>
    
    public let updateEnabled: Driver<Bool>
    
    public let validatedAddressName = PublishSubject<ValidationResult>()
    public let validatedAddressNote = PublishSubject<ValidationResult>()
    public let latlong = PublishSubject<(lat: Double, lon: Double, address: String)?>()

    
    private let _submitProperty = PublishSubject<Void>()

    private let delegate = UIApplication.shared.delegate as! AppDelegateType

    public init(
        id: Int?,
        name: Driver<String?>,
        detail: Driver<String?>,
        activityIndicator: ActivityIndicator
        ) {
                    
        let cache = AddressSQLCache<AddressRequest>(dbQueue: delegate.dbQueue)
        
        let useCase = UpdateAddressUseCaseProvider(
            service: UpdateAddressCloudService<Detail<Address>>(),
            cache: cache,
            activityIndicator: activityIndicator)
        
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<Response>()
        let failedProperty = PublishSubject<Status.Detail>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        dismissResponder = dismissResponderProperty.asDriver(onErrorJustReturn: false)
            let coordinates = latlong.asDriver(onErrorDriveWith: .empty())
        
            let validatedCoordinates: Driver<ValidationResult> = coordinates.flatMapLatest { value in
            if value == nil {
                return .just(.empty)
            }
            
            return .just(.ok(message: nil))
        }
        let validatedAddressName1: Driver<ValidationResult> = name.flatMapLatest { name in
            guard let name = name else{return .just(.empty)}
            if name.isEmpty{
                return .just(.empty)
            }
            return .just(.ok(message: nil))
        }
        
        let validatedAddressNote: Driver<ValidationResult> = detail.flatMapLatest { detail in
            guard let detail = detail else{return .just(.empty)}
            if detail.isEmpty{
                return .just(.empty)
            }
            return .just(.ok(message: nil))
        }
        
        updateEnabled = Driver.combineLatest(validatedAddressName1, validatedAddressNote, validatedCoordinates) {
            name, detail, coordinates in
            name.isValid && detail.isValid  && coordinates.isValid
        }.distinctUntilChanged()
        
        let forms: Driver<AddressRequest?> = Driver.combineLatest(name, detail, coordinates) { name, detail, coordinates in
            guard let name = name, let detail = detail, let coordinates = coordinates else { return nil }
            
            return AddressRequest(addressID: id,
                           name: name,
                           notes: detail,
                           lat: coordinates.lat,
                           lon: coordinates.lon,
                           address: coordinates.address)
        }
        
        update = _submitProperty.asDriver(onErrorJustReturn: ()).withLatestFrom(forms)
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
                case let .fail(status, _):
                    failedProperty.onNext(status)
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
    
    public func checkAddressNameValidation(addressName: String) {
        if addressName.isEmpty {
            validatedAddressName.onNext(.failed(message: "Please add a name for this address"))
        }  else {
            validatedAddressName.onNext(.ok(message: "address-name-hint".l10n()))
        }
    }
    
    public func checkAddressNoteValidation(addressNote: String) {
        if addressNote.isEmpty {
            validatedAddressNote.onNext(.failed(message: "Please add note for more information related to your address"))
        } else {
            validatedAddressNote.onNext(.ok(message: "add-note-hint".l10n()))
        }
    }
    
    public func updateLatLong(lat: Double?, long: Double?, address: String?){
        guard let lat = lat, let long = long, let address = address else {return}
        latlong.onNext((lat: lat, lon: long, address: address))
    }
}
