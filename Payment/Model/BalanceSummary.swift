//
//  BalanceSummary.swift
//  Payment
//
//  Created by Fandy Gotama on 27/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct BalanceSummary: Codable, ResponseType {
    public let errors: [DataError]?
    public let status: Status.Detail
    public let data: Data?
    
    public struct Data: Codable {
        public let balance: Balance
        public let hold: Hold
        
        public struct Balance: Codable {
            public let amount: Decimal
            public let currency: String
        }
        
        public struct Hold: Codable {
            public let amount: Decimal
            public let currency: String
        }
        
        enum CodingKeys: String, CodingKey {
            case balance
            case hold = "onHold"
        }
    }
}
