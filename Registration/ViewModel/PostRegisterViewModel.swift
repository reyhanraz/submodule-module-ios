//
//  PostRegisterViewModel.swift
//  Registration
//
//  Created by Reyhan Rifqi Azzami on 22/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import Common
import RxSwift
import RxCocoa
import Platform
import Domain
import ServiceWrapper

public struct PostRegisterViewModel: PostRegistrationViewModelType, PostRegistrationViewModelOutput{
    
    public typealias T = RegisterResponse
    
    public typealias Outputs = PostRegisterViewModel
    public var outputs: Outputs { return self }
    
    public var loading: Driver<Loading>
    public var register: Driver<Void>
    public var success: Driver<T>
    public var failed: Driver<(Status.Detail, [DataError]?)>
    public var exception: Driver<Exception>
    public var dismissResponder: Driver<Bool>
    
    private let _requestProperty = PublishSubject<ServiceWrapper.RegisterRequest>()

    
    public init<U: UseCase>(
        useCase: U
        ) where U.R == ServiceWrapper.RegisterRequest, U.T == T, U.E == Error {
                
        let loadingProperty = PublishSubject<Loading>()
        let successProperty = PublishSubject<T>()
        let failedProperty = PublishSubject<(Status.Detail, [DataError]?)>()
        let exceptionProperty = PublishSubject<Exception>()
        let dismissResponderProperty = PublishSubject<Bool>()
        
        loading = loadingProperty.asDriver(onErrorDriveWith: .empty())
        success = successProperty.asDriver(onErrorDriveWith: .empty())
        failed = failedProperty.asDriver(onErrorDriveWith: .empty())
        exception = exceptionProperty.asDriver(onErrorDriveWith: .empty())
        dismissResponder = dismissResponderProperty.asDriver(onErrorJustReturn: false)
        
        register = _requestProperty
                .asDriver(onErrorDriveWith: .empty())
            .do(onNext: { _ in
                loadingProperty.onNext(Loading(start: true, text: "registering".l10n()))
                dismissResponderProperty.onNext(true)
            })
            .flatMapLatest { request in
                return useCase.execute(request: request).asDriver(onErrorDriveWith: .empty())
            }
            .do(onNext: { _ in loadingProperty.onNext(Loading(start: false, text: "register".l10n())) })
            .flatMapLatest { result in
                switch result {
                case let .success(register):
                    successProperty.onNext(register)
                case let .fail(status, errors):
                    failedProperty.onNext((status, errors))
                case let .error(error):
                    exceptionProperty.onNext(Exception(title: "registration_failed".l10n(), message: "registration_error_message".l10n(), error: error))
                default:
                    return .empty()
                }
                
                return .empty()
        }
    }
    
    public func execute(request: ServiceWrapper.RegisterRequest?, challenge_token: String){
        guard let request = request else { return }

        let _request = ServiceWrapper.RegisterRequest(name: request.name,
                                                      email: request.email,
                                                      password: request.password,
                                                      gender: request.gender,
                                                      challenge_token: challenge_token,
                                                      type: request.type)
        
        _requestProperty.onNext(_request)
    }
    
}



public protocol PostRegistrationViewModelOutput {
    associatedtype T
    
    var loading: Driver<Loading> { get }
    var register: Driver<Void> { get }
    var success: Driver<T> { get }
    var failed: Driver<(Status.Detail, [DataError]?)> { get }
    var exception: Driver<Exception> { get }
    var dismissResponder: Driver<Bool> { get }
}

protocol PostRegistrationViewModelType {
    associatedtype Outputs = RegistrationViewModelOutput
    
    var outputs: Outputs { get }
}
