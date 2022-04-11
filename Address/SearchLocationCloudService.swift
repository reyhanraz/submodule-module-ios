//
//  SearchLocationCloudService.swift
//  Address
//
//  Created by Fandy Gotama on 29/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import Platform

public class SearchLocationCloudService<CloudResponse: ResponseType>: AddressAPI, ServiceType {
    public typealias R = String
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init(){
        super.init()
    }
    
    public func get(request: String?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        return super.searchLocation(keyword: request)
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
