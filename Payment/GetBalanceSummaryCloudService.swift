//
//  GetBalanceSummaryCloudService.swift
//  Payment
//
//  Created by Fandy Gotama on 27/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class GetBalanceSummaryCloudService<CloudResponse: ResponseType>: PaymentAPI, ServiceType {
    public typealias R = Void
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init(){
        super.init()
    }
    
    public func get(request: Void?) -> Observable<Result<T, Error>> {
        return super.getBalanceSummary()
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

