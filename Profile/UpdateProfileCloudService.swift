//
//  UpdateProfileCloudService.swift
//  Profile
//
//  Created by Fandy Gotama on 20/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct UpdateProfileCloudService<Request: Encodable, CloudResponse: ResponseType>: ServiceType {
    public typealias R = Request
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<ProfileApi<Request>>
    
    public init(service: MoyaProvider<ProfileApi<Request>> = MoyaProvider<ProfileApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: Request?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx
            .request(.update(request: request))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

