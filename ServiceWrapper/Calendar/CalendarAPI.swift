//
//  CalendarAPI.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 06/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import RxSwift
import Alamofire

open class CalendarAPI: ServiceHelper{
    
    public override init() {
        super.init()
    }
    
    public func getEventList(start: Date?, end: Date?, artisanId: Int) -> Observable<(Data?, HTTPURLResponse?)>{
        
        var params: [String : Any] = [:]
        params["artisanId"] = artisanId
        
        if let start = start {
            params["timeMin"] = start.toSystemDate
        }
        
        if let end = end {
            params["timeMax"] = end.toSystemDate
        }
        
        return super.request(Endpoint.artisanCalendar,
                             parameter: params)
        .retry(3).map { result in
            return (result.data, result.response)
        }
    }
}
