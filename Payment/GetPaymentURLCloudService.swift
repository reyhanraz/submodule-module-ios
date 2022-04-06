//
// Created by Fandy Gotama on 05/01/20.
// Copyright (c) 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class GetPaymentURLCloudService<CloudResponse: ResponseType>: PaymentAPI, ServiceType {
    public typealias R = PaymentRequest

    public typealias T = CloudResponse
    public typealias E = Error

    public override init(){
        super.init()
    }

    public func get(request: PaymentRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }

        let response: Observable<(Data?, HTTPURLResponse?)>

        if request.refund {
            response = super.getRefundURL(bookingId: request.bookingId)
        } else {
            response = super.getInvoiceURL(bookingId: request.bookingId, artisanId: request.artisanId)
        }

        return response
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

