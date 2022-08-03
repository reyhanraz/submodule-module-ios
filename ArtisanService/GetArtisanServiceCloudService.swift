//
//  GetArtisanServiceCloudService.swift
//  ArtisanService
//
//  Created by Reyhan Rifqi Azzami on 01/07/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class GetArtisanServiceCloudService: ArtisanServiceAPI, ServiceType {
    public typealias R = String
    
    public typealias T = Detail<ArtisanService>
    public typealias E = Error
    
    
    public override init() {
        super.init()
    }
    
    public func get(request: R?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.gatArtisanService(id: request)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
