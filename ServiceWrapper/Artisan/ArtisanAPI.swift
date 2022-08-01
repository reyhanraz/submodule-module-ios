//
//  ArtisanAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire
import L10n_swift

open class ArtisanAPI {
    public init(){ }
    
    public func getArtisanList(filter: ArtisanFilter) -> Observable<(Data?, HTTPURLResponse?)>{
        var params: [String: Any] = [:]
        
        params["page"] = filter.page
        params["limit"] = filter.limit
        
        if let ids = filter.categories {
            params["categoryIds"] = ids.map { $0.id }
        }
        
        if let ids = filter.categoryTypes {
            params["categoryTypeIds"] = ids.map { $0.id }
        }
        
        if let ratings = filter.ratings {
            params["rating"] = ratings
        }
        
        if let min = filter.priceMin {
            params["startPrice"] = min
        }
        
        if let max = filter.priceMax {
            params["toPrice"] = max
        }
        
        if let search = filter.keyword {
            params["search"] = search
        }
        
        if let timestamp = filter.timestamp {
            params["timestamp"] = timestamp * 1000
        }
        
        if let latitude = filter.latitude, let longitude = filter.longitude {
            params["lat"] = latitude
            params["lon"] = longitude
        }
        
        if filter.listType == .trending {
            params["trending"] = true
        }
        
        if let order = filter.order{
            params["order"] = order
        }
        
        if let orderBy = filter.orderBy{
            params["orderBy"] = orderBy
        }
        
        //categories[0]:2
        //categories[1]:
        //price:true
        
        if filter.listType == .editorChoice{
    
            return ServiceHelper.shared.request(Endpoint.editorChoice).retry(3).map { result in
                return (result.data, result.response)
            }
            
        } else {
            
            let endpoint = "\(Endpoint.listUser)/artisan"
            
            return ServiceHelper.shared.request(endpoint, parameter: params, encoding: URLEncoding.queryString).retry(3).map { result in
                return (result.data, result.response)
            }
            
        }
        
        
    }
    
    public func getDetailArtisan(id: String) -> Observable<(Data?, HTTPURLResponse?)>{
        let endpoint  = "\(Endpoint.listUser)/\(id)"
        return ServiceHelper.shared.request(endpoint).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getFavoriteList(request: ArtisanFilter) -> Observable<(Data?, HTTPURLResponse?)>{
        var params: [String : Any] = [:]

        params["page"] = request.page
        params["limit"] = request.limit
        
        return ServiceHelper.shared.request(Endpoint.getFavoriteListArtisan, parameter: params).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getNearbyArtisan(request: ArtisanFilter) -> Observable<(Data?, HTTPURLResponse?)>{
        var params: [String : Any] = [:]
        
        params["page"] = request.page
        params["limit"] = request.limit
        
        if let latitude = request.latitude, let longitude = request.longitude {
            params["range"] = 20
            params["lat"] = latitude
            params["lng"] = longitude
        }
        return ServiceHelper.shared.request(Endpoint.getNearbyArtisan, parameter: params).retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
