//
//  CustomizeRequestCacheService.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 15/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Platform

public struct CustomizeRequestCacheService<R, Provider: Cache>: ServiceType where Provider.R == R, Provider.T == CustomizeRequest {
    
    public typealias R = Provider.R
    public typealias T = CustomizeRequestDetail
    public typealias E = Error
    
    private let _cache: Provider
    
    public init(cache: Provider) {
        _cache = cache
    }
    
    public func get(request: R?) -> Observable<Result<CustomizeRequestDetail, Error>> {
        guard let item = _cache.get(request: request) else { return .empty() }
        
        let data = CustomizeRequestDetail.Data(customizeRequest: item)
        let status = Status.Detail(code: 200, message: "")
        
        let model = CustomizeRequestDetail(status: status, data: data, errors: nil)
        
        return Observable
            .just(model)
            .map(Result.success)
            .catchError { error in return .just(.error(error)) }
    }
}
