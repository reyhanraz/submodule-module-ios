//
//  UpdateAddressCloudService.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import ServiceWrapper
import RxSwift
import Platform

public class UpdateAddressCloudService<CloudResponse: NewResponseType>: AddressAPI, ServiceType {
    public typealias R = AddressRequest
    
    public typealias T = CloudResponse
    public typealias E = Error
        
    public override init(){
        super.init()
    }
    
    public func get(request: AddressRequest?) -> Observable<Result<T, Error>> {
        guard let request = request else { return .just(.error(ServiceError.invalidRequest)) }
        
        let response: Observable<(Data?, HTTPURLResponse?)>
        
        if let id = request.id {
            response = super.updateAddress(id: id, request: request)
        } else {
            response = super.insertAddress(request: request)
        }
        
        return response
            .retry(3)
            .map { response in self.parse(data: response.0, statusCode: response.1?.statusCode) }
            .catchError { error in return .just(.error(error)) }
            .asObservable()
    }
}
