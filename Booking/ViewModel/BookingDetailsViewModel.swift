//
//  BookingDetailsViewModel.swift
//  Booking
//
//  Created by Reyhan Rifqi Azzami on 25/01/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Domain
import Common
import CommonUI

public struct BookingDetailsViewModel: ViewModelType {
    public typealias DataRequest = BookingListRequest
    public typealias DataResponse = BookingDetails
    
    // MARK: Outputs
    public let result: Driver<(DataRequest?, DataResponse)>
    public let loading: Driver<Loading>
    public let failed: Driver<Status.Detail>
    public let exception: Driver<Error>
    public let unauthorized: Driver<Unauthorized>
    
    // MARK: Private
    private let _requestProperty = PublishSubject<DataRequest?>()
    
    public init<U: UseCase>(loadingText: String? = nil, loadInitialCache: Bool = false, useCase: U) where U.R == DataRequest, U.T == DataResponse, U.E == Error {
        
        let loadingProperty = PublishSubject<Loading>()
        let exceptionProperty = PublishSubject<Error>()
        let failedProperty = PublishSubject<Status.Detail>()
        let unauthorizedProperty = PublishSubject<Unauthorized>()
        
        loading = loadingProperty.asDriver(onErrorJustReturn: Loading(start: false))
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        unauthorized = unauthorizedProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        
        let requestCache: Driver<(Request?, DataResponse)>?
        
        if loadInitialCache {
            requestCache = _requestProperty
                .asDriver(onErrorDriveWith: .empty())
                .flatMapLatest { request -> Driver<(Request, Result<DataResponse, Error>)> in
                    guard let request = request else { return .empty() }
                    
                    return useCase.executeCache(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
            }.flatMapLatest({ result -> Driver<(Request?, DataResponse)> in
                switch result.1 {
                case let .success(list):
                    return .just((result.0, list))
                default:
                    return .empty()
                }
            })
        } else {
            requestCache = nil
        }
        
        let request = _requestProperty
            .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: true, text: loadingText)) })
            .flatMap { request -> Driver<(Request?, Result<DataResponse, Error>)> in
                return useCase.execute(request: request).map { (request, $0) }.asDriver(onErrorDriveWith: .empty())
        }
        .do(onNext: { _ in loadingProperty.onNext(Loading(start: false)) })
        .flatMap({ result -> Driver<(DataRequest?, DataResponse)> in
            switch result.1 {
            case let .success(data):
               return .just((result.0, data))
            case .unauthorized:
                unauthorizedProperty.onNext(Unauthorized(title: "load_failed".l10n()))
                
                return .empty()
            case let .fail(status, _):
                failedProperty.onNext(status)
                
                return .empty()
            case let .error(error):
                exceptionProperty.onNext(error)
                
                return .empty()
            }
        })
        
        if let cache = requestCache {
            result = Driver.merge(cache, request)
        } else {
            result = request
        }
    }
    
    public func execute(request: DataRequest? = nil) {
        _requestProperty.onNext(request)
    }
}

