//
//  AddressAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire
import L10n_swift

open class AddressAPI: ServiceHelper{
    public override init(){
        super.init()
    }
    
    public func getAddressList() -> Observable<(Data?, HTTPURLResponse?)>{
        let param = ["page": 1]
        return super.request(Endpoint.getAddressList, parameter: param).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func insertAddress(request: AddressRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request(Endpoint.addressDetails, method: .post ,parameter: request, encoding: JSONEncoding.default).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func updateAddress(id: Int, request: AddressRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request(Endpoint.addressDetails, method: .put ,parameter: request, encoding: JSONEncoding.default).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func deleteAddress(id: Int) -> Observable<(Data?, HTTPURLResponse?)>{
        let param = ["id": id]
        return super.request(Endpoint.addressDetails, method: .delete, parameter: param).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func updateLocation(lat: Double, lon: Double) -> Observable<(Data?, HTTPURLResponse?)>{
        let param = ["lat": lat, "lng": lon]
        return super.request(Endpoint.addressDetails, method: .post, parameter: param, encoding: JSONEncoding.default).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func searchLocation(keyword: String) -> Observable<(Data?, HTTPURLResponse?)>{
        let param = ["search": keyword, "limit": 50] as [String : Any]
        return super.request(Endpoint.searchLocation, parameter: param).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getProvinceList() -> Observable<(Data?, HTTPURLResponse?)>{
        let param = ["page": 1, "limit": 10000] as [String : Any]
        return super.request(Endpoint.getProvinceList, parameter: param).retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
