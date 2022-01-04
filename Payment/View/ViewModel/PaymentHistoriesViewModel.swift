//
//  PaymentHistoriesViewModel.swift
//  Payment
//
//  Created by Fandy Gotama on 28/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Domain
import Common
import CommonUI

public struct PaymentHistoriesViewModel<ListRequest: ListRequestType>: ListViewModelType {
    public typealias Request = ListRequest
    public typealias Response = GroupedPaymentHistory
    
    // MARK: Inputs
    let loadMore = BehaviorSubject<Bool>(value: false)
    
    // MARK: Outputs
    public let result: Driver<(Request, [GroupedPaymentHistory], Paging?, Bool)>
    public let loading: Driver<Loading>
    public let failed: Driver<Status.Detail>
    public let exception: Driver<Error>
    public let unauthorized: Driver<Unauthorized>
    
    // MARK: Private
    private let _getListProperty = PublishSubject<Request>()
    private let _loadMoreProperty = PublishSubject<Request>()
     
    public init<U: UseCase>(useCase: U, loadInitialCache: Bool = false) where U.R == Request, U.T == List<PaymentHistory>, U.E == Error {
        var items = [PaymentHistory]()
        var isShouldClearItems = false
        
        let loadingProperty = PublishSubject<Loading>()
        let exceptionProperty = PublishSubject<Error>()
        let failedProperty = PublishSubject<Status.Detail>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        
        loading = loadingProperty.asDriver(onErrorJustReturn: Loading(start: false))
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        
        let requestCache: Driver<(Request, List<PaymentHistory>, Bool)>?
        
        if loadInitialCache {
            requestCache = _getListProperty
                .asDriver(onErrorDriveWith: .empty())
                .flatMapLatest { request -> Driver<(Request, Result<List<PaymentHistory>, Error>)> in
                    return useCase.executeCache(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
                }.flatMapLatest({ result -> Driver<(Request, List<PaymentHistory>, Bool)> in
                    switch result.1 {
                    case let .success(list):
                        if (list.data?.list.count ?? 0) > 0 {
                            loadingProperty.onNext(Loading(start: false))
                        }
                        return .just((result.0, list, true))
                    default:
                        return .empty()
                    }
                })
        } else {
            requestCache = nil
        }
        
        let initialRequest = _getListProperty
            .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: true)) })
            .flatMap { request -> Driver<(Request, Result<List<PaymentHistory>, Error>)> in
                return useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, List<PaymentHistory>, Bool)> in
                switch result.1 {
                case let .success(list):
                    return .just((result.0, list, false))
                case .unauthorized:
                    unauthorizedProperty.onNext(Unauthorized(title: "load_list_failed".l10n()))
                    
                    return .empty()
                case let .fail(status, _):
                    failedProperty.onNext(status)
                    
                    return .empty()
                case let .error(error):
                    exceptionProperty.onNext(error)
                    
                    return .empty()
                }
            }).do(onNext: { _ in isShouldClearItems = true })
        
        let nextRequest = _loadMoreProperty
            .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: true)) })
            .flatMap { request -> Driver<(Request, Result<List<PaymentHistory>, Error>)> in
                return useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, List<PaymentHistory>, Bool)> in
                switch result.1 {
                case let .success(list):
                    return .just((result.0, list, false))
                default:
                    return .empty()
                }
            }).do(onNext: { _ in isShouldClearItems = false })
        
        func transform(list: [PaymentHistory]) -> [GroupedPaymentHistory] {
            var groups = [GroupedPaymentHistory]()
            var date: Date?
            var histories: [PaymentHistory]?
            
            list.forEach {
                if date?.toSystemDate != $0.createdAt.toSystemDate {
                    if let histories = histories, let date = date, !histories.isEmpty {
                        let grouped = GroupedPaymentHistory(date: date, histories: histories)
                    
                        groups.append(grouped)
                    }
                    
                    date = $0.createdAt
                    
                    histories = [PaymentHistory]()
                }
                    
                histories?.append($0)
            }
            
            if let histories = histories, let date = date, !histories.isEmpty {
                let grouped = GroupedPaymentHistory(date: date, histories: histories)
                
                groups.append(grouped)
            }
            
            return groups
        }
        
        if let cache = requestCache {
            result = Driver
                .merge(cache, initialRequest, nextRequest).map({ (request, dataResponse, isFromInitialCache) in
                if isShouldClearItems {
                    items.removeAll()
                }
                
                items += dataResponse.data?.list ?? []
                
                let groupedItems = transform(list: items)
                    
                return (request, groupedItems, dataResponse.data?.paging, isFromInitialCache)
            })
        } else {
            result = Driver.merge(initialRequest, nextRequest).map { (request, dataResponse, isFromInitialCache) in
                if isShouldClearItems {
                    items.removeAll()
                }
                
                items += dataResponse.data?.list ?? []
                
                let groupedItems = transform(list: items)
                
                return (request, groupedItems, dataResponse.data?.paging, isFromInitialCache)
            }
        }
    }
    
    public func get(request: Request) {
        _getListProperty.onNext(request)
    }
    
    public func loadMore(request: Request) {
        _loadMoreProperty.onNext(request)
    }
}




