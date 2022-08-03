//
//  CategoryListViewModel.swift
//  Category
//
//  Created by Reyhan Rifqi Azzami on 13/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//


import RxSwift
import RxCocoa
import Platform
import Domain
import Common

public struct CategoryListViewModel {
    public typealias Request = CategoryListRequest
    public typealias DataResponse = NewList<Category>
    public typealias Response = Category
    
    // MARK: Inputs
    let loadMore = BehaviorSubject<Bool>(value: false)
    
    // MARK: Outputs
    public let result: Driver<[Category]>
    public let loading: Driver<Loading>
    public let failed: Driver<Status.Detail>
    public let exception: Driver<Error>
    public let unauthorized: Driver<Unauthorized>
    
    // MARK: Private
    private let _getListProperty = PublishSubject<Request>()
    private let _loadMoreProperty = PublishSubject<Request>()
     
    public init<U: UseCase>(useCase: U) where U.R == Request, U.T == DataResponse, U.E == Error {
        var items = [Category]()
        var isShouldClearItems = false
        
        let loadingProperty = PublishSubject<Loading>()
        let exceptionProperty = PublishSubject<Error>()
        let failedProperty = PublishSubject<Status.Detail>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        
        loading = loadingProperty.asDriver(onErrorJustReturn: Loading(start: false))
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        
        let initialRequest = _getListProperty
            .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: true)) })
            .flatMap { request -> Driver<(Request, Result<DataResponse, Error>)> in
                return useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, DataResponse, Bool)> in
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
            .flatMap { request -> Driver<(Request, Result<DataResponse, Error>)> in
                return useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
            .flatMap({ result -> Driver<(Request, DataResponse, Bool)> in
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
                
                return items
        }
    }
    
    public func get(request: Request) {
        _getListProperty.onNext(request)
    }
    
    public func loadMore(request: Request) {
        _loadMoreProperty.onNext(request)
    }
}


