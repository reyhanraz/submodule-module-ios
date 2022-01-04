//
//  RatingCloudService.swift
//  Rating
//
//  Created by Fandy Gotama on 01/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct RatingCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = ListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<RatingApi>
    
    public init(service: MoyaProvider<RatingApi> = MoyaProvider<RatingApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: ListRequest?) -> Observable<Result<T, Error>> {
        guard let request = request, let id = request.id else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx
            .request(.getList(artisanId: id, page: request.page, limit: request.limit, timestamp: request.timestamp))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
