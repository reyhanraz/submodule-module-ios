//
//  BookingAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 15/07/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

//case getList(statuses: [Int]?, keyword: String?, page: Int, limit: Int, timestamp: TimeInterval?)
//case getDetail(id: Int)
import RxSwift
import Alamofire
import L10n_swift

open class BookingAPI{
    public init(){}
    
    public func getBookingList(statuses: [Int]?, keyword: String?, page: Int, limit: Int, timestamp: TimeInterval?) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.getBooking, parameter: nil).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getBookingDetail(id: String) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request("\(Endpoint.getBooking)/\(id)", parameter: nil).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func complaint(request: PostComplaintRequest) -> Observable<(Data?, HTTPURLResponse?)>{
        return ServiceHelper.shared.request(Endpoint.getBooking, method: .post, parameter: request, encoding: URLEncoding.httpBody).retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
//    public func updateBookingStatus(id: String, status: Int) -> Observable<(Data?, HTTPURLResponse?)>{
//        return super.request(Endpoint.getBooking, method: .post, parameter: request, encoding: URLEncoding.httpBody).retry(3).map { result in
//            return (result.data, result.response)
//        }
//    }

//case createBooking(request: PostBookingRequest)
//case updateBookingStatus(id: Int, status: Booking.Status)
//case updateCustomizeRequestStatus(id: Int, artisanId: Int?, price: Double?, status: Booking.Status)
//case checkAvailability(request: CheckAvailabilityRequest)
}
