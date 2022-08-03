//
//  ResendEmailCloudService.swift
//  Profile
//
//  Created by Reyhan Rifqi Azzami on 28/05/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import L10n_swift
import Platform
import ServiceWrapper

public class ResendEmailCloudService: ProfileAPI<Int>, ServiceType {
    
    public typealias R = Int
    
    public typealias T = Detail<BasicAPIResponse>
    public typealias E = Error
    
    public override init() {
        super.init()
    }
    
    public func get(request: Int?) -> Observable<Result<T, E>> {
        return resendEmailVerification().map { self.parse(data: $0.0, statusCode: $0.1?.statusCode)}
    }
}
