//
//  CustomizeRequestCloudService.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 07/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import RxSwift
import L10n_swift
import Platform

public struct CustomizeRequestCloudService<CloudResponse: ResponseType>: ServiceType {
    public typealias R = CustomizeListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    private let _service: MoyaProvider<CustomizeRequestApi>
    
    public init(service: MoyaProvider<CustomizeRequestApi> = MoyaProvider<CustomizeRequestApi>(plugins: [NetworkLoggerPlugin(verbose: true)])) {
        _service = service
    }
    
    public func get(request: CustomizeListRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Single<Response>
        
        if let id = request.id {
            response = _service.rx.request(.getDetail(id: id))
        } else {
            response = _service.rx.request(.getList(page: request.page, limit: request.limit, timestamp: request.timestamp))
        }
        
        return response
            .retry(3)
            .map(T.self)
            .map { response in self.parse(result: response) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
