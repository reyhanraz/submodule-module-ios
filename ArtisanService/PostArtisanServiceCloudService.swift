//
//  PostArtisanServiceCloudService.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 24/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Platform
import ServiceWrapper

public class PostArtisanServiceCloudService<CloudResponse: ResponseType>: ArtisanServiceAPI, ServiceType {
    public typealias R = ArtisanServiceRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
        
    public override init() {
        super.init()
    }
    
    public func get(request: ArtisanServiceRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Observable<(Data?, HTTPURLResponse?)>
        
        if let id = request.id {
            response = super.updateArtisanService(id: id, request: request)
        } else {
            response = super.insertArtisanService(request: request)
        }
        
        return response
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

