//
//  ArtisanServiceCloudService.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 25/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import Platform

public class ArtisanServiceCloudService<CloudResponse: ResponseType>: ArtisanServiceAPI, ServiceType {
    public typealias R = ListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
        
    public override init() {
        super.init()
    }
    
    public func get(request: ListRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.getArtisanServiceList(id: request.id, page: request.page, limit: request.limit, timestamp: request.timestamp)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

