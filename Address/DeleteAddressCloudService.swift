//
//  DeleteAddressCloudService.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct DeleteAddressCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = Int
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<AddressApi>
    
    public init(service: MoyaProvider<AddressApi> = MoyaProvider<AddressApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: Int?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx
            .request(.delete(id: request))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
