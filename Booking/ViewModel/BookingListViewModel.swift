//
//  BookingListViewModel.swift
//  Booking
//
//  Created by Reyhan Rifqi Azzami on 24/01/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Domain
import Common
import CommonUI
import Foundation

public struct BookingListViewModel{
    public typealias Request = BookingListRequest
    public typealias Response = NewList<Booking>

    public var loading: Driver<Loading>
    public var result: Driver<(Request, [Booking], Bool)>
    public var failed: Driver<Status.Detail>
    public var arrayResult: Driver<[Booking]>
    
    private let _getListProperty = PublishSubject<Request>()
    private let _loadMoreProperty = PublishSubject<Request>()
            
    private let delegate = UIApplication.shared.delegate as! AppDelegateType

    
    public init(activityIndicator: ActivityIndicator){
        let loadingProperty = PublishSubject<Loading>()
        let failedProperty = PublishSubject<Status.Detail>()
        let arrayResultProperty = PublishSubject<[Booking]>()


        loading = loadingProperty.asDriver(onErrorJustReturn: Loading(start: false))
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        arrayResult = arrayResultProperty.asDriver(onErrorDriveWith: .empty())
        
        let cache = BookingSQLCache(dbQueue: delegate.dbQueue, tableName: TableNames.Booking.booking)
        
        let _useCase = NewListUseCaseProvider(
                service: BookingCloudService<NewList<Booking>>(),
                cacheService: NewListCacheService<BookingListRequest, NewList<Booking>, BookingSQLCache>(cache: cache),
                cache: cache,
                insertToCache: false,
                activityIndicator: activityIndicator)
        
        var items = [Booking]()
        var isShouldClearItems = false
        
        let initialRequest = _getListProperty
            .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: true)) })
            .flatMap { request -> Driver<(Request, Result<NewList<Booking>, Error>)> in
                return _useCase.execute(request: request)
                    .map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, NewList<Booking>, Bool)> in
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
            .flatMap { request -> Driver<(Request, Result<NewList<Booking>, Error>)> in
                return _useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, NewList<Booking>, Bool)> in
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
    
    public func get(bookingID: String? = nil) {
        let request = BookingListRequest()
        request.id = bookingID
        request.forceReload = true
        _getListProperty.onNext(request)
    }
    
    public func loadMore(request: BookingListRequest) {
        _loadMoreProperty.onNext(request)

    }
    
}
