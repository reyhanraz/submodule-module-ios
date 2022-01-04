//
//  PostArtisanServiceCloudService.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 24/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import Platform

public struct PostArtisanServiceCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = ArtisanServiceRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<ArtisanServiceApi>
    
    public init(service: MoyaProvider<ArtisanServiceApi> = MoyaProvider<ArtisanServiceApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: ArtisanServiceRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Single<Response>
        
        if let id = request.id {
            response = _service.rx.request(.update(id: id, request: request))
        } else {
            response = _service.rx.request(.insert(request: request))
        }
        
        return response
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

