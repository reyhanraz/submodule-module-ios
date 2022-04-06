//
//  ProvinceCloudService.swift
//  Address
//
//  Created by Fandy Gotama on 10/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import Platform

public class ProvinceCloudService<CloudResponse: ResponseType>: AddressAPI, ServiceType {
    public typealias R = ListRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
    
    public override init(){
        super.init()
    }
    
    public func get(request: ListRequest?) -> Observable<Result<T, Error>> {
        
        return super.getProvinceList()
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
