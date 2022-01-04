//
//  PaymentApi.swift
//  Payment
//
//  Created by Fandy Gotama on 27/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum PaymentApi {
    case getInvoiceURL(bookingId: Int, artisanId: Int?)
    case getRefundURL(bookingId: Int)
    case getPayoutURL(amount: Double)
    case getBalanceSummary
    case getPaymentHistories(page: Int, limit: Int)
    case getHistoryDetail(id: Int)
}

extension PaymentApi: TargetType {
    public var baseURL: URL {
        return PlatformConfig.host
    }

    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }

    public var path: String {
        switch self {
        case let .getInvoiceURL(_, artisanId):
            return artisanId != nil ? "\("config.serverless".l10n())customRequestPaymentInit" : "\("config.serverless".l10n())bookingPayment"
        case .getRefundURL:
            return "\("config.serverless".l10n())bookingPaymentRefundInit"
        case .getPayoutURL:
            return "\("config.serverless".l10n())initPayout"
        case .getBalanceSummary:
            return "\("config.serverless".l10n())\("config.path".l10n())PaymentBalance"
        case .getPaymentHistories:
            return "\("config.serverless".l10n())bookingPaymentSummaryHistories"
        case .getHistoryDetail:
            return "\("config.serverless".l10n())bookingPaymentSummaryHistory"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .getPayoutURL:
            return .put
        default:
            return .get
        }
    }

    public var sampleData: Data { Data() }

    public var task: Task {
        switch self {
        case let .getInvoiceURL(bookingId, artisanId):
            var params = [String : Any]()

            params["bookingId"] = bookingId

            if let artisanId = artisanId {
                params["artisanId"] = artisanId
            }

            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        case let .getRefundURL(bookingId):
            return .requestParameters(parameters: ["bookingId": bookingId], encoding: URLEncoding.queryString)
        case let .getPayoutURL(amount):
            return .requestParameters(parameters: ["payoutAmount": amount], encoding: JSONEncoding.default)
        case let .getPaymentHistories(page, limit):
            return .requestParameters(parameters: ["page": page, "limit": limit], encoding: URLEncoding.queryString)
        case let .getHistoryDetail(id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        case .getBalanceSummary:
            return .requestPlain
        }
    }
}

