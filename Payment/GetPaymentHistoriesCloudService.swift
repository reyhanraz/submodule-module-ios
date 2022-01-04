//
//  GetPaymentHistoriesCloudService.swift
//  Payment
//
//  Created by Fandy Gotama on 28/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import Platform

public struct GetPaymentHistoriesCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = ListRequest

    public typealias T = CloudResponse
    public typealias E = Error

    private let _service: MoyaProvider<PaymentApi>

    public init(service: MoyaProvider<PaymentApi> = MoyaProvider<PaymentApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }

    public func get(request: ListRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }

        return _service.rx.request(.getPaymentHistories(page: request.page, limit: request.limit))
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
