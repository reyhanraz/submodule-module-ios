//
//  ForgotPasswordCloudService.swift
//  ForgotPassword
//
//  Created by Fandy Gotama on 18/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct ForgotPasswordCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = ForgotPasswordRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<ForgotPasswordApi>
    
    public init(service: MoyaProvider<ForgotPasswordApi> = MoyaProvider<ForgotPasswordApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: ForgotPasswordRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx
            .request(.forgotPassword(request: request))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
