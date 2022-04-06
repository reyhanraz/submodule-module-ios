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

open class ArtisanAPI: ServiceHelper{
    public override init(){
        super.init()
    }
    
    public func getArtisanList(filter: ArtisanFilter) -> Observable<(Data?, HTTPURLResponse?)>{
        var params: [String: Any] = [:]
        
        params["page"] = filter.page
        params["limit"] = filter.limit
        
        if let locations = filter.locations {
            params["districtIds"] = locations.map { $0.id }
        }
        
        if let ids = filter.categories {
            params["categoryIds"] = ids.map { $0.id }
        }
        
        if let ids = filter.categoryTypes {
            params["categoryTypeIds"] = ids.map { $0.id }
        }
        
        if let ratings = filter.ratings {
            params["ratings"] = ratings
        }
        
        if let min = filter.priceMin {
            params["priceMin"] = min
        }
        
        if let max = filter.priceMax {
            params["priceMax"] = max
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

        if let isEditorChoice = filter.isEditorChoice {
            params["isEditorChoice"] = isEditorChoice
        }
        
        return super.request(Endpoint.getListArtisan, parameter: params).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getDetailArtisan(id: Int) -> Observable<(Data?, HTTPURLResponse?)>{
        let param = ["id": id]
        return super.request(Endpoint.getDetailArtisan, parameter: param).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getFavoriteList(request: ArtisanFilter) -> Observable<(Data?, HTTPURLResponse?)>{
        var params: [String : Any] = [:]

        params["page"] = request.page
        params["limit"] = request.limit
        
        return super.request(Endpoint.getFavoriteListArtisan, parameter: params).retry(3).map { result in
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
        return super.request(Endpoint.getNearbyArtisan, parameter: params).retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
