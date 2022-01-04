//
//  ProvinceCloudService.swift
//  Address
//
//  Created by Fandy Gotama on 10/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import Platform

public struct ProvinceCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = ListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<AddressApi>
    
    public init(service: MoyaProvider<AddressApi> = MoyaProvider<AddressApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: ListRequest?) -> Observable<Result<T, Error>> {
        
        return _service.rx
            .request(.getProvinceList)
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
