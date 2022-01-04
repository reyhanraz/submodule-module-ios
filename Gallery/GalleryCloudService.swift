//
//  GalleryCloudService.swift
//  Gallery
//
//  Created by Fandy Gotama on 13/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import Platform

public struct GalleryCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = ListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<GalleryApi>
    
    public init(service: MoyaProvider<GalleryApi> = MoyaProvider<GalleryApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: ListRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx
            .request(.getGalleries(kind: request.kind ?? .customer, id: request.id ?? 0, page: request.page, limit: request.limit, timestamp: request.timestamp))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
