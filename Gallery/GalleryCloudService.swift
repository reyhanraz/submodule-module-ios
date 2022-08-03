//
//  GalleryCloudService.swift
//  Gallery
//
//  Created by Fandy Gotama on 13/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import Platform

public class GalleryCloudService<CloudResponse: NewResponseType>: GalleryAPI, ServiceType {
    public typealias R = NewListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
        
    public override init() {
        super.init()
    }
    
    public func get(request: R?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.getGalleries(kind: request.kind ?? .customer, id: request.id ?? "", page: request.page, limit: request.limit, timestamp: request.timestamp)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
