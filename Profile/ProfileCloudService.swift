//
//  ProfileCloudService.swift
//  Profile
//
//  Created by Fandy Gotama on 20/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import L10n_swift
import Platform
import ServiceWrapper

//public class ProfileCloudService<Request: Encodable, CloudResponse: ResponseType>: ProfileAPI<Request>, ServiceType {
//
//    public typealias R = Int
//
//    public typealias T = CloudResponse
//    public typealias E = Error
//
//    public override init() {
//        super.init()
//    }
//
//    public func get(request: Int?) -> Observable<Result<T, E>> {
//        return getDetailProfile(request: request).map { self.parse(data: $0.0, statusCode: $0.1?.statusCode)}
//    }
//}

public class ProfileCloudService<Request: Encodable, CloudResponse: NewResponseType>: ProfileAPI<Request>, ServiceType {
    
    public typealias R = String
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init() {
        super.init()
    }
    
    public func get(request: R?) -> Observable<Result<T, E>> {
        return getDetailProfile().map { self.parse(data: $0.0, statusCode: $0.1?.statusCode)}
    }
}
