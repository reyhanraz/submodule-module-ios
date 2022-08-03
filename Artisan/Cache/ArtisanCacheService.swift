//
//  ArtisanCacheService.swift
//  Artisan
//
//  Created by Fandy Gotama on 16/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Platform

public struct ArtisanCacheService<R, Provider: Cache>: ServiceType where Provider.R == R, Provider.T == Artisan {
    
    public typealias R = Provider.R
    public typealias T = Detail<Artisan>
    public typealias E = Error
    
    private let _cache: Provider
    
    public init(cache: Provider) {
        _cache = cache
    }
    
    public func get(request: R?) -> Observable<Result<T, Error>> {
        guard let item = _cache.get(request: request) else { return .empty() }
        
        return Observable
            .just(Detail(data: item))
            .map(Result.success)
            .catchError { error in return .just(.error(error)) }
    }
}
