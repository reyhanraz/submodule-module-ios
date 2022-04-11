//
//  PaymentAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 06/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire

open class PaymentAPI: ServiceHelper{
    
    public override init() {
        super.init()
    }
    
    public func getPayoutURL(amount: Double) -> Observable<(Data?, HTTPURLResponse?)>{
        return super.request(Endpoint.initPayout,
                             method: HTTPMethod.put,
                             parameter: ["payoutAmount": amount],
                             encoding: JSONEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getInvoiceURL(bookingId: Int, artisanId: Int?) -> Observable<(Data?, HTTPURLResponse?)>{
        
        let endpoint = artisanId != nil ? Endpoint.customRequestPaymentInit : Endpoint.bookingPayment
        
        var params: [String : Any] = [:]
        
        params["bookingId"] = bookingId

        if let artisanId = artisanId {
            params["artisanId"] = artisanId
        }
        
        return super.request(endpoint,
                             parameter: params)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getRefundURL(bookingId: Int) -> Observable<(Data?, HTTPURLResponse?)>{
        
        return super.request(Endpoint.bookingPaymentRefundInit,
                             parameter: ["bookingId": bookingId])
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getBalanceSummary() -> Observable<(Data?, HTTPURLResponse?)>{
        
        return super.request(Endpoint.balanceSummary,
                             parameter: nil,
                             encoding: URLEncoding.default)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getPaymentHistories(page: Int, limit: Int) -> Observable<(Data?, HTTPURLResponse?)>{
        
        return super.request(Endpoint.bookingPaymentSummaryHistories,
                             parameter: ["page": page, "limit": limit])
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
    
    public func getHistoryDetail(id: Int) -> Observable<(Data?, HTTPURLResponse?)>{
        
        return super.request(Endpoint.bookingPaymentSummaryHistories,
                             parameter: ["id": id])
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
