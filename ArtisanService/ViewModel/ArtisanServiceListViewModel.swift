//
//  ArtisanServiceListViewModel.swift
//  ArtisanService
//
//  Created by Reyhan Rifqi Azzami on 22/06/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Domain
import Common
import CommonUI
import ServiceWrapper

public struct ArtisanServiceListViewModel{
    public typealias Request = ServiceListRequest
    public typealias Response = NewList<ArtisanService>

    public var loading: Driver<Loading>
    public var result: Driver<(Request, [ArtisanService], Bool)>
    public var failed: Driver<Status.Detail>
    
    private let _getListProperty = PublishSubject<Request>()
    private let _getListFiltered = PublishSubject<Request>()
    private let _loadMoreProperty = PublishSubject<Request>()
            
    private let delegate = UIApplication.shared.delegate as! AppDelegateType

    
    public init(activityIndicator: ActivityIndicator){
        let loadingProperty = PublishSubject<Loading>()
        let failedProperty = PublishSubject<Status.Detail>()
        
        loading = loadingProperty.asDriver(onErrorJustReturn: Loading(start: false))
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        
        let cache = ArtisanServiceSQLCache<ServiceListRequest>(dbQueue: delegate.dbQueue)
        
        let _useCase = NewListUseCaseProvider(
            service: ArtisanServiceCloudService(),
            cacheService: NewListCacheService<ServiceListRequest, NewList<ArtisanService>, ArtisanServiceSQLCache<ServiceListRequest>>(cache: cache),
            cache: cache, insertToCache: true,
            activityIndicator: activityIndicator)
        
        var items = [ArtisanService]()
        var isShouldClearItems = false
        
        
        let requestCache = _getListFiltered
                .asDriver(onErrorDriveWith: .empty())
                .flatMapLatest { request -> Driver<(Request, Result<NewList<ArtisanService>, Error>)> in
                    return _useCase.executeCache(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
                }.flatMapLatest({ result -> Driver<(Request, NewList<ArtisanService>, Bool)> in
                    switch result.1 {
                    case let .success(list):
                        if list.data.count > 0 {
                            loadingProperty.onNext(Loading(start: false))
                        }
                        
                        return .just((result.0, list, true))
                    default:
                        return .empty()
                    }
                })
        
        let initialRequest = _getListProperty
            .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: true)) })
            .flatMap { request -> Driver<(Request, Result<NewList<ArtisanService>, Error>)> in
                return _useCase.execute(request: request)
                    .map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, NewList<ArtisanService>, Bool)> in
                switch result.1 {
                case let .success(list):
                    return .just((result.0, list, false))
                case let .fail(status, _):
                    failedProperty.onNext(status)
                    
                    return .empty()
                default:
                    return .empty()
                }
            }).do(onNext: { _ in isShouldClearItems = true })
        
        let nextRequest = _loadMoreProperty
            .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: true)) })
            .flatMap { request -> Driver<(Request, Result<NewList<ArtisanService>, Error>)> in
                return _useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, NewList<ArtisanService>, Bool)> in
                switch result.1 {
                case let .success(list):
                    return .just((result.0, list, false))
                case let .fail(status, _):
                    failedProperty.onNext(status)
                    
                    return .empty()
                default:
                    return .empty()
                }
            }).do(onNext: { _ in isShouldClearItems = false })
        
        result = Driver.merge(initialRequest, nextRequest, requestCache).map { (request, dataResponse, isFromInitialCache) in
            if isShouldClearItems {
                items.removeAll()
            }
            
            items += dataResponse.data
            
            return (request, items, isFromInitialCache)
        }
    }
    
    public func get(request: ServiceListRequest) {
        _getListProperty.onNext(request)
    }
    
    public func loadMore(request: ServiceListRequest) {
        _loadMoreProperty.onNext(request)

    }
    
    public func filterService(request: ServiceListRequest) {
        _getListFiltered.onNext(request)

    }
    
}
