//
// Created by Fandy Gotama on 05/01/20.
// Copyright (c) 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct GetPaymentURLCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = PaymentRequest

    public typealias T = CloudResponse
    public typealias E = Error

    private let _service: MoyaProvider<PaymentApi>

    public init(service: MoyaProvider<PaymentApi> = MoyaProvider<PaymentApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }

    public func get(request: PaymentRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }

        let response: Single<Response>

        if request.refund {
            response = _service.rx.request(.getRefundURL(bookingId: request.bookingId))
        } else {
            response = _service.rx.request(.getInvoiceURL(bookingId: request.bookingId, artisanId: request.artisanId))
        }

        return response
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

