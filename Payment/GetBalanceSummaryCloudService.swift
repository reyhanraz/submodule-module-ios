//
//  GetBalanceSummaryCloudService.swift
//  Payment
//
//  Created by Fandy Gotama on 27/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct GetBalanceSummaryCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = Void
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<PaymentApi>
    
    public init(service: MoyaProvider<PaymentApi> = MoyaProvider<PaymentApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: Void?) -> Observable<Result<T, Error>> {
        return _service.rx.request(.getBalanceSummary)
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}

