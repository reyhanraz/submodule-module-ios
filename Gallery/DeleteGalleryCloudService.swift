//
//  DeleteGalleryCloudService.swift
//  Gallery
//
//  Created by Fandy Gotama on 16/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import Platform

public struct DeleteGalleryCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = [Int]
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<GalleryApi>
    
    public init(service: MoyaProvider<GalleryApi> = MoyaProvider<GalleryApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: [Int]?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return _service.rx
            .request(.deleteGalleries(ids: request))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

