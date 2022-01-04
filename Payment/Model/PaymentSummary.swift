//
// Created by Fandy Gotama on 04/01/20.
// Copyright (c) 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct PaymentSummary: Codable {
    public let summary: Summary?
    public let invoices: [Invoice]
    public let refunds: [Refund]?

    public struct Invoice: Codable {
        public let invoiceNumber: String
        public let providerInvoiceURL: URL
        public let providerInvoiceCreateRequest: ProviderInvoiceCreateRequest
        public let paymentPaidAmount: Decimal?
        public let paymentMethod: String?
        public let paymentChannel: String?

        public struct ProviderInvoiceCreateRequest: Codable {
            public let failureRedirect: URL
            public let successRedirect: URL

            enum CodingKeys: String, CodingKey {
                case failureRedirect = "failure_redirect_url"
                case successRedirect = "success_redirect_url"
            }
        }

        enum CodingKeys: String, CodingKey {
            case invoiceNumber
            case providerInvoiceURL = "providerInvoiceUrl"
            case providerInvoiceCreateRequest
            case paymentPaidAmount
            case paymentMethod
            case paymentChannel
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let decodedPaymentPaidAmount = try container.decodeIfPresent(String.self, forKey: .paymentPaidAmount)

            invoiceNumber = try container.decode(String.self, forKey: .invoiceNumber)
            providerInvoiceURL = try container.decode(URL.self, forKey: .providerInvoiceURL)
            providerInvoiceCreateRequest = try container.decode(ProviderInvoiceCreateRequest.self, forKey: .providerInvoiceCreateRequest)
            paymentMethod = try container.decodeIfPresent(String.self, forKey: .paymentMethod)
            paymentChannel = try container.decodeIfPresent(String.self, forKey: .paymentChannel)

            if let amount = decodedPaymentPaidAmount {
                paymentPaidAmount = Decimal(string: amount)
            } else {
                paymentPaidAmount = nil
            }
        }
    }

    public struct Refund: Codable {
        public let providerPayoutPasscode: String?
        public let providerPayoutURL: URL?

        enum CodingKeys: String, CodingKey {
            case providerPayoutPasscode
            case providerPayoutURL = "providerPayoutUrl"
        }
    }

    public struct Summary: Codable {
        public let toRefundAmount: Decimal?
        public let createdAt: Date
        public let updatedAt: Date

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let decodedCreated = try container.decode(String.self, forKey: .createdAt)
            let decodedUpdated = try container.decode(String.self, forKey: .updatedAt)
            let decodedRefundAmount = try container.decodeIfPresent(String.self, forKey: .toRefundAmount)

            createdAt = decodedCreated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
            updatedAt = decodedUpdated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()

            if let amount = decodedRefundAmount {
                toRefundAmount = Decimal(string: amount)
            } else {
                toRefundAmount = nil
            }
        }
    }
}

extension PaymentSummary {
    public var invoiceURL: URL? {
        invoices.first?.providerInvoiceURL
    }

    public var paidAmount: Decimal? {
        invoices.first?.paymentPaidAmount
    }

    public var paymentChannelAndMethod: String? {
        if let method = invoices.first?.paymentMethod, let channel = invoices.first?.paymentChannel {
            return "\(channel) - \(method)"
        }

        return nil
    }

    public var refundURL: URL? {
        refunds?.first?.providerPayoutURL
    }

    public var payoutPasscode: String? {
        refunds?.first?.providerPayoutPasscode
    }

    public var invoiceNumber: String? {
        invoices.first?.invoiceNumber
    }

    public var isRefundable: Bool {
        if let refundAmount = summary?.toRefundAmount, refundAmount > 0 {
            return true
        }

        return false
    }

    public var isPaymentPaid: Bool {
        if let paidAmount = paidAmount {
            return paidAmount > 0 ? true : false
        }
        return false
    }

    public var successURL: URL? {
        invoices.first?.providerInvoiceCreateRequest.successRedirect
    }

    public var failedURL: URL? {
        invoices.first?.providerInvoiceCreateRequest.failureRedirect
    }
}
