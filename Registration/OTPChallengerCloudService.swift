//
//  OTPChallengerCloudService.swift
//  Registration
//
//  Created by Reyhan Rifqi Azzami on 18/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class OTPChallengerCloudService: RegisterAPI, ServiceType {    
    public typealias R = ChallengerRequest

    public typealias T = Detail<ChallengerRequest>
    public typealias E = Error


    public override init() {
        super.init()
    }

    public func get(request: ChallengerRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let service: Observable<(Data?, HTTPURLResponse?)>
        
        if request.secret != nil{
            service = self.validateOTP(request: request)
        }else{
            service = self.requestOTP(request: request)
        }
        
        return service.map { (data, response) in
            self.parse(data: data, statusCode: response?.statusCode)
        }
    }
}
