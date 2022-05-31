//
//  MetadataCloudService.swift
//  Profile
//
//  Created by Reyhan Rifqi Azzami on 27/05/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import L10n_swift
import Platform
import ServiceWrapper

public class MetadataCloudService: MetadataAPI, ServiceType {
    
    public typealias R = MetadataRequest
    
    public typealias T = Detail<NewProfile>
    public typealias E = Error
        
    public override init() {
        super.init()
    }
    
    public func get(request: MetadataRequest?) -> Observable<Result<T, E>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        if request.editCurrentValue {
            return editMetadata(request: request).map { self.parse(data: $0.0, statusCode: $0.1?.statusCode)}
        } else {
            return addMetadata(request: request).map { self.parse(data: $0.0, statusCode: $0.1?.statusCode)}
        }
    }
}
