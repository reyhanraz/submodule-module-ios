//
//  ArtisanCloudService.swift
//  Artisan
//
//  Created by Fandy Gotama on 07/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import Platform

public struct ArtisanCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = ArtisanFilter
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<ArtisanApi>
    
    public init(service: MoyaProvider<ArtisanApi> = MoyaProvider<ArtisanApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: ArtisanFilter?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Single<Response>
        
        if let id = request.id {
            response = _service.rx.request(.getDetail(id: id))
        } else if request.latitude != nil && request.longitude != nil {
            response = _service.rx.request(.getNearby(request: request))
        } else if request.listType == .favorite {
            response = _service.rx.request(.getFavoriteList(request: request))
        } else {
            response = _service.rx.request(.getList(request: request))
        }
        
        return response
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
