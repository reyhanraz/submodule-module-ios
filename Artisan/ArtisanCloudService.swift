//
//  ArtisanCloudService.swift
//  Artisan
//
//  Created by Fandy Gotama on 07/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import Platform

public class ArtisanCloudService<CloudResponse: ResponseType>: ArtisanAPI, ServiceType {
    public typealias R = ArtisanFilter
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init() {
        super.init()
    }
    
    public func get(request: ArtisanFilter?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
                
        let response: Observable<(Data?, HTTPURLResponse?)>
        
        if let id = request.id {
            response = super.getDetailArtisan(id: id)
        } else if request.latitude != nil && request.longitude != nil {
            response = super.getNearbyArtisan(request: request)
        } else if request.listType == .favorite {
            response = super.getFavoriteList(request: request)
        } else {
            response = super.getArtisanList(filter: request)
        }
        
        return response
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
