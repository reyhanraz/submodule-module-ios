//
//  AddressCloudService.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import L10n_swift
import Platform

public class AddressCloudService<CloudResponse: ResponseType>: AddressAPI, ServiceType {
    
    public typealias R = ListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init() {
        super.init()
    }
    
    public func get(request: ListRequest?) -> Observable<Result<T, Error>> {
        guard request != nil else { return .just(.error(ServiceError.invalidRequest)) }
        return super.getAddressList()
            .retry(3)
            .map { data, response in
                self.parse(data: data, statusCode: response?.statusCode)
            }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
