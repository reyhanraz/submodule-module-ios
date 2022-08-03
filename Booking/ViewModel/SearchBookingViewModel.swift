//
//  SearchBookingViewModel.swift
//  Booking
//
//  Created by Fandy Gotama on 26/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Domain
import CommonUI
import Common

public struct SearchBookingViewModel<ServiceResponse: NewResponseListType>: SearchViewModelType {
    
    public typealias Response = ServiceResponse.T
    
    // MARK: Outputs
    public let result: Driver<[Response]>
    public let loading: Driver<Loading>
    public let failed: Driver<Void>
    
    // MARK: Private
    private let _getListProperty = PublishSubject<Void>()
    private let _searchProperty = PublishSubject<String>()
    
    public init<U: UseCase>(keyword: Observable<String>? = nil, searchAfter: Int, useCase: U) where U.R == BookingListRequest, U.T == ServiceResponse, U.E == Error {
        var items = [Response]()
        var isShouldClearItems = false
        
        let loadingProperty = PublishSubject<Loading>()
        let failedProperty = PublishSubject<Void>()
        
        loading = loadingProperty.asDriver(onErrorJustReturn: Loading(start: false))
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        
        let savedResults = _getListProperty
            .asDriver(onErrorDriveWith: .empty())
            .flatMapLatest { request -> Driver<Result<ServiceResponse, U.E>> in
                return useCase.executeCache(request: BookingListRequest()).asDriver(onErrorDriveWith: .empty())
            }.flatMapLatest({ result -> Driver<[Response]> in
                switch result {
                case let .success(response):
                    return .just(response.data)
                default:
                    return .empty()
                }
            })
        
        func search(keyword: Observable<String>) -> Driver<[Response]> {
            return keyword.debounce(.milliseconds(500), scheduler: MainScheduler.instance)
                .distinctUntilChanged()
                .filter { $0.count >= searchAfter }
                .asDriver(onErrorDriveWith: .empty())
                .do(onNext: { _ in loadingProperty.onNext(Loading(start: true)) })
                .flatMap({ request -> Driver<Result<ServiceResponse, Error>> in
                    let filter = BookingListRequest(page: 1)
                    
                    filter.keyword = request
                    
                    return useCase.execute(request: filter).asDriver(onErrorDriveWith: .empty())
                })
                .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
                .flatMap({ result -> Driver<[Response]> in
                    switch result {
                    case let .success(response):
                        return .just(response.data)
                    default:
                        failedProperty.onNext(())
                        
                        return .empty()
                    }
                }).do(onNext: { _ in isShouldClearItems = true })
        }
        
        let searchResults: Driver<[Response]>
        
        if let keyword = keyword {
            searchResults = search(keyword: keyword)
        } else {
            searchResults = search(keyword: _searchProperty.asObservable())
        }
        
        result = Driver.merge(savedResults, searchResults).map {
            if isShouldClearItems {
                items.removeAll()
            }
            
            items += $0
            
            return items
        }
    }
    
    public func loadSavedResults() {
        _getListProperty.onNext(())
    }
    
    public func search(keyword: String) {
        _searchProperty.onNext(keyword)
    }
}



