//
//  PaymentHistoryDetail.swift
//  Payment
//
//  Created by Fandy Gotama on 31/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct PaymentHistoryDetail: Codable, ResponseType {
    public let errors: [DataError]?
    public let status: Status.Detail
    public let data: Data?
    
    public enum PaymentStatus: Int, Codable {
        case pending
        case paid
        case credited
        case refunded
        case toCredit
        case toRefund
    }
    
    public struct Data: Codable {
        public let detail: Detail
        
        public struct Detail: Codable {
            public let id: Int
            public let bookingId: Int?
            public let artisanId: Int?
            public let customerId: Int?
            public let typeId: Int
            public let paymentStatus: PaymentStatus
            public let chargedAmount: Decimal?
            public let transactionPaidAmount: Decimal?
            public let transactionFee: Decimal
            public let transactionReceivedAmount: Decimal?
            public let createdAt: Date
            public let bookingName: String?
            public let bookingReferenceId: String?
            public let customer: NewProfile?
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                let decodedCreatedAt = try container.decode(String.self, forKey: .createdAt)
                let decodedChargedAmount = try container.decodeIfPresent(String.self, forKey: .chargedAmount)
                let decodedPaidAmount = try container.decodeIfPresent(String.self, forKey: .transactionPaidAmount)
                let decodedFee = try container.decodeIfPresent(String.self, forKey: .transactionFee)
                let decodedReceivedAmount = try container.decodeIfPresent(String.self, forKey: .transactionReceivedAmount)
                
                id = try container.decode(Int.self, forKey: .id)
                typeId = try container.decode(Int.self, forKey: .typeId)
                paymentStatus = try container.decode(PaymentStatus.self, forKey: .paymentStatus)
                
                bookingId = try container.decodeIfPresent(Int.self, forKey: .bookingId)
                artisanId = try container.decodeIfPresent(Int.self, forKey: .artisanId)
                customerId = try container.decodeIfPresent(Int.self, forKey: .customerId)
                bookingName = try container.decodeIfPresent(String.self, forKey: .bookingName)
                bookingReferenceId = try container.decodeIfPresent(String.self, forKey: .bookingReferenceId)
                customer = try container.decodeIfPresent(NewProfile.self, forKey: .customer)

                createdAt = decodedCreatedAt.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
                
                if let amount = decodedChargedAmount {
                    chargedAmount = Decimal(string: amount) ?? nil
                } else {
                    chargedAmount = nil
                }
                
                if let amount = decodedPaidAmount {
                    transactionPaidAmount = Decimal(string: amount) ?? nil
                } else {
                    transactionPaidAmount = nil
                }
                
                if let amount = decodedFee {
                    transactionFee = Decimal(string: amount) ?? 0
                } else {
                    transactionFee = 0
                }
                
                if let amount = decodedReceivedAmount {
                    transactionReceivedAmount = Decimal(string: amount) ?? nil
                } else {
                    transactionReceivedAmount = nil
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case id
                case bookingId
                case artisanId
                case customerId
                case typeId
                case paymentStatus = "statusId"
                case chargedAmount
                case transactionPaidAmount
                case transactionFee
                case transactionReceivedAmount
                case createdAt
                case bookingName = "booking_name"
                case bookingReferenceId = "booking_reference_id"
                case customer
            }
        }
        
        enum CodingKeys: String, CodingKey {
            case detail = "paymentSummaryHistory"
        }
    }
}

extension PaymentHistoryDetail.Data.Detail {
    public var amount: Decimal? {
        if let amount = transactionReceivedAmount {
            return amount
        } else if let amount = transactionPaidAmount {
            return amount
        }
        
        return chargedAmount
    }
    
    public var statusName: String {
        switch paymentStatus {
        case .credited:
            return "credited".l10n()
        case .paid:
            return "paid".l10n()
        case .pending:
            return "pending".l10n()
        case .refunded:
            return "refunded".l10n()
        case .toCredit:
            return "to_credit".l10n()
        case .toRefund:
            return "to_refund".l10n()
        }
    }
}
