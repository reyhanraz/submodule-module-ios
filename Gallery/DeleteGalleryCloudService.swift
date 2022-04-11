//
//  DeleteGalleryCloudService.swift
//  Gallery
//
//  Created by Fandy Gotama on 16/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import Platform

public class DeleteGalleryCloudService<CloudResponse: ResponseType>: GalleryAPI, ServiceType {
    public typealias R = [Int]
    
    public typealias T = CloudResponse
    public typealias E = Error
        
    public override init() {
        super.init()
    }
    
    public func get(request: [Int]?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.deleteGallery(ids: request)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

