//
//  UpdateFavoriteCloudService.swift
//  Favorite
//
//  Created by Fandy Gotama on 03/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct UpdateFavoriteCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = FavoriteRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<FavoriteApi>
    
    public init(service: MoyaProvider<FavoriteApi> = MoyaProvider<FavoriteApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: FavoriteRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Single<Response>
        
        if request.action == .add {
            response = _service.rx.request(.add(artisanId: request.id))
        } else {
            response = _service.rx.request(.remove(artisanId: request.id))
        }
        
        return response
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
