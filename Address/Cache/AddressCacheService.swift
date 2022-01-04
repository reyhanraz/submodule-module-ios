//
//  AddressCacheService.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import RxSwift

public struct AddressCacheService<DataResponse: ResponseListType, Provider: Cache>: ServiceType where Provider.R == ListRequest, Provider.T == Address {
    
    public typealias R = Provider.R
    public typealias T = DataResponse
    public typealias E = Error
    
    private let _cache: Provider
    
    public init(cache: Provider) {
        _cache = cache
    }
    
    public func get(request: ListRequest?) -> Observable<Result<DataResponse, Error>> {
        let list = _cache.getList(request: request)
        
        let data = Addresses.ListData(list: list)
        let status = Status.Detail(code: 200, message: "")
        
        guard let model = Addresses(data: data, status: status) as? DataResponse else { fatalError() }
        
        return Observable
            .just(model)
            .map(Result.success)
            .catchError { error in return .just(.error(error)) }
    }
}
