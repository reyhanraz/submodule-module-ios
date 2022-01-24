//
//  BookingListViewModel.swift
//  Booking
//
//  Created by Reyhan Rifqi Azzami on 24/01/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Domain
import Common
import CommonUI
import Foundation

public struct BookingListViewModel {
    
    // MARK: Outputs
    public let result = PublishSubject<[Booking]>()
        
    private let serviceAPI: ServiceAPI
     
    public init(service: ServiceAPI) {
        self.serviceAPI = service
    }
    
    public func load(){
        serviceAPI.fetchData(url: "https://private-anon-3f6ccb4b78-beautybell.apiary-mock.com/api/v1/bookings", decode: ListBooking.self, completionHandler: { result in
            switch result{
            case .success(let response):
                self.result.onNext(response.data)
            case .error(_):
                break
            case .unauthorized:
                break
            case .fail(status: _, errors: _):
                break
            }
        })
    }
}


import Alamofire

public protocol ServiceAPI{
    func fetchData<T: Codable>(url: String, decode: T.Type, completionHandler: @escaping (Result<T, Error>) -> Void)
}

public struct DataService: ServiceAPI {
    
    // MARK: - Singleton
    public static let shared = DataService()
    
    // MARK: - Services
    public func fetchData<T: Codable>(url: String, decode: T.Type, completionHandler: @escaping (Result<T, Error>) -> Void){
        AF.request(url)
            .validate(contentType: ["application/json"])
            .responseDecodable(of: decode.self){ response in
                guard let value = response.value else {return}
                completionHandler(.success(value))
            }
        
    }
}

public struct ListBooking: Codable{
    public let data: [Booking]
}
