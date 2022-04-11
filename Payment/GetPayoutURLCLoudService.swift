//
//  GetPayoutURLCLoudService.swift
//  Payment
//
//  Created by Fandy Gotama on 31/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import Platform

public class GetPayoutURLCloudService<CloudResponse: ResponseType>: PaymentAPI, ServiceType {
    public typealias R = Double

    public typealias T = CloudResponse
    public typealias E = Error

    public override init() {
        super.init()
    }

    public func get(request: Double?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }

        return super.getPayoutURL(amount: request)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
