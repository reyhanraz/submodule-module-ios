//
//  ChangePasswordCloudService.swift
//  ChangePassword
//
//  Created by Fandy Gotama on 21/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct ChangePasswordCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = ChangePasswordRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<ChangePasswordApi>
    
    public init(service: MoyaProvider<ChangePasswordApi> = MoyaProvider<ChangePasswordApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: ChangePasswordRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx
            .request(.change(request: request))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
