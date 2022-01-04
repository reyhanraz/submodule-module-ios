//
//  CategoryTypeCacheService.swift
//  Category
//
//  Created by Fandy Gotama on 22/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Platform

public struct CategoryTypeCacheService<DataResponse: ResponseListType, Provider: Cache>: ServiceType where Provider.R == ListRequest, Provider.T == CategoryType {
    
    public typealias R = ListRequest
    public typealias T = DataResponse
    public typealias E = Error
    
    private let _cache: Provider
    
    public init(cache: Provider) {
        _cache = cache
    }
    
    public func get(request: ListRequest?) -> Observable<Result<DataResponse, Error>> {
        let list = _cache.getList(request: request)
        
        let data = CategoryTypes.ListData(list: list, paging: nil)
        let status = Status.Detail(code: 200, message: "")
        
        guard let model = CategoryTypes(data: data, status: status) as? DataResponse else { fatalError() }
        
        return Observable
            .just(model)
            .map(Result.success)
            .catchError { error in return .just(.error(error)) }
    }
}
