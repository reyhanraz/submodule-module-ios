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
import ServiceWrapper

public struct AddressViewModel{
    public typealias Request = ListRequest
    public typealias Response = NewList<Address>

    public var loading: Driver<Loading>
    public var result: Driver<(ListRequest, [Address], Bool)>
    public var failed: Driver<Status.Detail>
    public var arrayResult: Driver<[Address]>
    
    private let _getListProperty = PublishSubject<Request>()
    private let _loadMoreProperty = PublishSubject<Request>()
            
    private let delegate = UIApplication.shared.delegate as! AppDelegateType

    
    public init(activityIndicator: ActivityIndicator){
        let loadingProperty = PublishSubject<Loading>()
        let failedProperty = PublishSubject<Status.Detail>()
        let arrayResultProperty = PublishSubject<[Address]>()


        loading = loadingProperty.asDriver(onErrorJustReturn: Loading(start: false))
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        arrayResult = arrayResultProperty.asDriver(onErrorDriveWith: .empty())
        
        let cache = AddressSQLCache<ListRequest>(dbQueue: delegate.dbQueue)
        
        let _useCase = NewListUseCaseProvider(
            service: AddressCloudService<NewList<Address>>(),
            cacheService: AddressCacheService<NewList<Address>, AddressSQLCache<ListRequest>>(cache: cache),
            cache: cache,
            activityIndicator: activityIndicator)
        
        var items = [Address]()
        var isShouldClearItems = false
        
        let initialRequest = _getListProperty
            .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: true)) })
            .flatMap { request -> Driver<(Request, Result<NewList<Address>, Error>)> in
                return _useCase.execute(request: request)
                    .map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, NewList<Address>, Bool)> in
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
            .flatMap { request -> Driver<(Request, Result<NewList<Address>, Error>)> in
                return _useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, NewList<Address>, Bool)> in
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
            
            items += dataResponse.data
            arrayResultProperty.onNext(items)
            
            return (request, items, isFromInitialCache)
        }
    }
    
    public func get(addressID: Int? = nil) {
        let request = ListRequest()
        request.id = addressID
        request.forceReload = true
        _getListProperty.onNext(request)
    }
    
    public func loadMore(request: ListRequest) {
        _loadMoreProperty.onNext(request)

    }
    
}


