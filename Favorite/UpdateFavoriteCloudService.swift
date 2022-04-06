//
//  UpdateFavoriteCloudService.swift
//  Favorite
//
//  Created by Fandy Gotama on 03/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class UpdateFavoriteCloudService<CloudResponse: ResponseType>: FavoriteAPI, ServiceType {
    public typealias R = FavoriteRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init() {
        super.init()
    }
    
    public func get(request: FavoriteRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Observable<(Data?, HTTPURLResponse?)>
        
        if request.action == .add {
            response = super.setFavorite(artisanID: request.id)
        } else {
            response = super.removeFavorite(artisanID: request.id)
        }
        
        return response
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
