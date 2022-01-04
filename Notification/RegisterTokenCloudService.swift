//
//  RegisterTokenCloudService.swift
//  Notification
//
//  Created by Fandy Gotama on 25/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct RegisterTokenCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = String
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<NotificationApi>
    
    public init(service: MoyaProvider<NotificationApi> = MoyaProvider<NotificationApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: String?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx
            .request(.register(token: request))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
