//
//  AddressViewModel.swift
//  Address
//
//  Created by Reyhan Rifqi Azzami on 15/10/21.
//  Copyright © 2021 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Domain
import Common
import CommonUI
import Alamofire
import Moya

public struct AddressViewModel{
    public typealias Request = ListRequest
    public typealias Response = Addresses.Data.T
    public typealias Detail = AddressDetail

    public var loading: Driver<Loading>
    public var result: Driver<(ListRequest, [Addresses.Data.T], Paging?, Bool)>
    public var failed: Driver<Status.Detail>
    public var arrayResult: Driver<[Addresses.Data.T]>
    
    public var failedUpdate: Driver<(Status.Detail, [DataError]?)>
    public var exception: Driver<Exception>
    public var success: Driver<Detail>
    public var unauthorized: Driver<Unauthorized>
    public var dismissResponder: Driver<Bool>
    public var update: Driver<Void>
    
    private let _getListProperty = PublishSubject<Request>()
    private let _loadMoreProperty = PublishSubject<Request>()
    
    public let deleteSuccess = PublishSubject<Void>()
    public let validatedAddressName = PublishSubject<ValidationResult>()
    public let validatedAddressNote = PublishSubject<ValidationResult>()
    public let latlong = PublishSubject<(lat: Double, lon: Double, address: String)?>()
    public var updateEnabled: Driver<Bool>
    
    private let _submitProperty = PublishSubject<Void>()
    
    private let _service = MoyaProvider<AddressApi>()
    private let delegate = UIApplication.shared.delegate as! AppDelegateType
    private let activityIndicator: ActivityIndicator

    
    public init(activityIndicator: ActivityIndicator){
        let loadingProperty = PublishSubject<Loading>()
        let failedProperty = PublishSubject<Status.Detail>()
        let arrayResultProperty = PublishSubject<[Addresses.Data.T]>()

        loading = loadingProperty.asDriver(onErrorJustReturn: Loading(start: false))
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        arrayResult = arrayResultProperty.asDriver(onErrorDriveWith: .empty())
        result = PublishSubject<(ListRequest, [Addresses.Data.T], Paging?, Bool)>().asDriver(onErrorDriveWith: .empty())
        
        failedUpdate = PublishSubject<(Status.Detail, [DataError]?)>().asDriver(onErrorDriveWith: .empty())
        exception = PublishSubject<Exception>().asDriver(onErrorDriveWith: .empty())
        success = PublishSubject<Detail>().asDriver(onErrorDriveWith: .empty())
        unauthorized = PublishSubject<Unauthorized>().asDriver(onErrorDriveWith: .empty())
        dismissResponder = PublishSubject<Bool>().asDriver(onErrorDriveWith: .empty())
        update = PublishSubject<Void>().asDriver(onErrorDriveWith: .empty())
        updateEnabled = PublishSubject<Bool>().asDriver(onErrorDriveWith: .empty())
        
        self.activityIndicator = activityIndicator
    }
    
    public mutating func getList(){
        let cache = AddressSQLCache<ListRequest>(dbQueue: delegate.dbQueue)
        
        let _useCase = ListUseCaseProvider(
            service: AddressCloudService<Addresses>(),
            cacheService: AddressCacheService<Addresses, AddressSQLCache<ListRequest>>(cache: cache),
            cache: cache,
            activityIndicator: activityIndicator)
        
        var items = [Addresses.Data.T]()
        var isShouldClearItems = false

        let loadingProperty = PublishSubject<Loading>()
        let failedProperty = PublishSubject<Status.Detail>()
        let arrayResultProperty = PublishSubject<[Addresses.Data.T]>()

        
        loading = loadingProperty.asDriver(onErrorJustReturn: Loading(start: false))
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        arrayResult = arrayResultProperty.asDriver(onErrorDriveWith: .empty())
        
        let initialRequest = _getListProperty
            .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: true)) })
            .flatMap { request -> Driver<(Request, Result<Addresses, Error>)> in
                
                return _useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, Addresses, Bool)> in
                switch result.1 {
                case let .success(list):
                    return .just((result.0, list, false))
                case .unauthorized:
                    return .empty()
                case let .fail(status, _):
                    failedProperty.onNext(status)
                    
                    return .empty()
                case .error(_):
                    return .empty()
                }
            }).do(onNext: { _ in isShouldClearItems = true })
        
        let nextRequest = _loadMoreProperty
            .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: true)) })
            .flatMap { request -> Driver<(Request, Result<Addresses, Error>)> in
                return _useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, Addresses, Bool)> in
                switch result.1 {
                case let .success(list):
                    return .just((result.0, list, false))
                default:
                    return .empty()
                }
            }).do(onNext: { _ in isShouldClearItems = false })
        
        result = Driver.merge(initialRequest, nextRequest).map { (request, dataResponse, isFromInitialCache) in
            if isShouldClearItems {
                items.removeAll()
            }
            
            items += dataResponse.data?.list ?? []
            arrayResultProperty.onNext(items)
            
            return (request, items, dataResponse.data?.paging, isFromInitialCache)
        }
    }
    
    public func deleteAddress(addressID: Int){
        _service.request(.delete(id: addressID)) { result in
            switch result{
            case .success(_):
                deleteSuccess.onNext(())
            case .failure(_):
                break
            }
        }
    }
    
    public func get(request: ListRequest) {
        _getListProperty.onNext(request)
    }
    
    public func loadMore(request: ListRequest) {
        _loadMoreProperty.onNext(request)

    }
    
    public func checkAddressNameValidation(addressName: String) {
        if addressName.isEmpty {
            validatedAddressName.onNext(.failed(message: "Please add a name for this address"))
        } else if addressName.count < 2 {
            validatedAddressName.onNext(.failed(message: "invalid_length".l10n(args: [2, 20])))
        } else {
            validatedAddressName.onNext(.ok(message: nil))
        }
    }
    
    public func checkAddressNoteValidation(addressNote: String) {
        if addressNote.isEmpty {
            validatedAddressNote.onNext(.failed(message: "Please add note for more information related to your address"))
        } else if addressNote.count < 2 {
            validatedAddressNote.onNext(.failed(message: "invalid_length".l10n(args: [2, 100])))
        }else {
            validatedAddressNote.onNext(.ok(message: nil))
        }
    }
    
    public func updateLatLong(lat: Double?, long: Double?, address: String?){
        guard let lat = lat, let long = long, let address = address else {return}
        latlong.onNext((lat: lat, lon: long, address: address))
    }
    
    public mutating func insertAddress(
        id: Int?,
        name: Driver<String?>,
        detail: Driver<String?>,
        coordinates: Driver<(lat: Double, lon: Double, address: String)?>,
        activityIndicator: ActivityIndicator
        ) {
                    
        let cache = AddressSQLCache<AddressRequest>(dbQueue: delegate.dbQueue)
        
        let useCase = UpdateAddressUseCaseProvider(
            service: UpdateAddressCloudService<AddressDetail>(),
            cache: cache,
            activityIndicator: activityIndicator)
        
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<Detail>()
        let failedProperty = PublishSubject<(Status.Detail, [DataError]?)>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        failedUpdate = failedProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        dismissResponder = dismissResponderProperty.asDriver(onErrorJustReturn: false)
        
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
        
        let forms = Driver.combineLatest(name, detail, coordinates) { name, detail, coordinates in
            AddressRequest(addressID: id, name: name, note: detail, lat: coordinates?.lat, lon: coordinates?.lon, address: coordinates?.address, rawAddress: nil)
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
}


