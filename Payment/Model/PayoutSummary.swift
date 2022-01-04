//
//  PayoutSummary.swift
//  Payment
//
//  Created by Fandy Gotama on 31/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct PayoutSummary: Codable, ResponseType {
    public let errors: [DataError]?
    public let status: Status.Detail
    public let data: Data?
    
    public struct Data: Codable {
        public let payout: Payout

        public struct Payout: Codable {
            public let payoutNumber: String
            public let payoutAmount: Decimal
            public let validUntil: Date
            public let payoutPasscode: String
            public let payoutURL: URL
            
            enum CodingKeys: String, CodingKey {
                case payoutNumber
                case payoutAmount
                case validUntil
                case payoutPasscode = "providerPayoutPasscode"
                case payoutURL = "providerPayoutUrl"
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)

                let decodedValid = try container.decode(String.self, forKey: .validUntil)
                
                payoutNumber = try container.decode(String.self, forKey: .payoutNumber)
                payoutAmount = try container.decode(Decimal.self, forKey: .payoutAmount)
                payoutPasscode = try container.decode(String.self, forKey: .payoutPasscode)
                payoutURL = try container.decode(URL.self, forKey: .payoutURL)
                
                validUntil = decodedValid.toDate(format: "yyyy-MM-dd HH:mm:ss") ?? Date()
            }
        }
    }
}
