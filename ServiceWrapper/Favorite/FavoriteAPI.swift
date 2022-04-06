//
//  FavoriteAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire

open class FavoriteAPI: ServiceHelper{
    public override init() {
        super.init()
    }
    
    public func setFavorite(artisanID: Int) -> Observable<(Data?, HTTPURLResponse?)>{
        let param = ["artisanId": artisanID]
        
        return super.request(Endpoint.addFavorite,
                             method: HTTPMethod.post,
                             parameter: param,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func removeFavorite(artisanID: Int) -> Observable<(Data?, HTTPURLResponse?)>{
        let param = ["artisanId": artisanID]
        
        return super.request(Endpoint.removeFavorite,
                             method: HTTPMethod.post,
                             parameter: param,
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
