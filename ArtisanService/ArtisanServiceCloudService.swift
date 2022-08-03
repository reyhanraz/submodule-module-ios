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

public class ArtisanServiceCloudService: ArtisanServiceAPI, ServiceType {
    public typealias R = ServiceListRequest
    
    public typealias T = NewList<ArtisanService>
    public typealias E = Error
        
    public override init() {
        super.init()
    }
    
    public func get(request: R?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.getArtisanServiceList(request: request)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

