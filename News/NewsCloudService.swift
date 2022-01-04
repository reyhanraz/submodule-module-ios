//
//  NewsCloudService.swift
//  News
//
//  Created by Fandy Gotama on 27/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import Platform

public struct NewsCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = ListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<NewsApi>
    
    public init(service: MoyaProvider<NewsApi> = MoyaProvider<NewsApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: ListRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Single<Response>
        
        if let id = request.id {
            response = _service.rx.request(.getDetail(id: id))
        } else {
            response = _service.rx.request(.getList(page: request.page, limit: request.limit, timestamp: request.timestamp))
        }
        
        return response
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
