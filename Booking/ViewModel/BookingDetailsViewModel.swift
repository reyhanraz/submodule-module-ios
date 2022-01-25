//
//  BookingDetailsViewModel.swift
//  Booking
//
//  Created by Reyhan Rifqi Azzami on 25/01/22.
//  Copyright © 2022 PT. Perintis Teknologi Nusantara. All rights reserved.
//

import Foundation
import RxSwift

public struct BookingDetailsViewModel {
    
    // MARK: Outputs
    public let result = PublishSubject<Booking>()
        
    private let serviceAPI: ServiceAPI
     
    public init(service: ServiceAPI) {
        self.serviceAPI = service
    }
    
    public func load(bookingID: String?){
        serviceAPI.fetchData(url: "https://private-anon-3f6ccb4b78-beautybell.apiary-mock.com/api/v1/bookings/id", decode: DetailBooking.self, completionHandler: { result in
            switch result{
            case .success(let response):
                guard let booking = response.data else {return}
                self.result.onNext(booking)
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

struct DetailBooking: Codable {
    let data: Booking?
}
