//
//  CategoryAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire
import L10n_swift


open class CategoryAPI: ServiceHelper{
    public override init(){
        super.init()
    }
    
    public func getCategories() -> Observable<(Data?, HTTPURLResponse?)>{
        let params: [String : Any] = [:]
        
        return super.request(Endpoint.getCategories,
                             parameter: params)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getCategoryTypes() -> Observable<(Data?, HTTPURLResponse?)>{
        let params: [String : Any] = [:]

        return super.request(Endpoint.getCategoryTypes,
                             parameter: params)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
