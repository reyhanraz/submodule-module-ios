//
//  BookingApi.swift
//  Booking
//
//  Created by Fandy Gotama on 29/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Moya
import Platform
import L10n_swift

public enum BookingApi {
    case complaint(request: PostComplaintRequest)
    case createBooking(request: PostBookingRequest)
    case getList(statuses: [Int]?, keyword: String?, page: Int, limit: Int, timestamp: TimeInterval?)
    case getDetail(id: Int)
    case updateBookingStatus(id: Int, status: Booking.Status)
    case updateCustomizeRequestStatus(id: Int, artisanId: Int?, price: Double?, status: Booking.Status)
    case checkAvailability(request: CheckAvailabilityRequest)
}

extension BookingApi: TargetType {
    
    public var baseURL: URL {
        return PlatformConfig.host
    }
    
    public var headers: [String : String]? {
        return PlatformConfig.httpHeaders
    }
    
    public var path: String {
        switch self {
        case .createBooking, .getDetail:
            return "\("config.serverless".l10n())booking"
        case .complaint:
            return "\("config.serverless".l10n())bookingComplaint"
        case let .updateBookingStatus(_, status):
            switch status {
            case .confirmed:
                return "\("config.serverless".l10n())setBookingStatusConfirmed"
            case .process:
                return "\("config.serverless".l10n())setBookingStatusProcess"
            case .completed:
                return "\("config.serverless".l10n())setBookingStatusCompleted"
            case .canceledByArtisan:
                return "\("config.serverless".l10n())setBookingStatusCanceledByArtisan"
            case .canceledByCustomer:
                return "\("config.serverless".l10n())setBookingStatusCanceledByCustomer"
            default:
                return "\("config.serverless".l10n())setBookingStatus"
            }
        case let .checkAvailability(request):
            if request.customRequestServiceRequests != nil {
                return "\("config.serverless".l10n())isCustomRequestScheduleAvailable"
            } else {
                return "\("config.serverless".l10n())isServiceScheduleAvailable"
            }
        case let .updateCustomizeRequestStatus(_, _, _, status):
            if status == .canceledByArtisan {
                return "\("config.serverless".l10n())customRequestBidCancel"
            } else if status == .bid {
                return "\("config.serverless".l10n())customRequestBid"
            } else {
                return "\("config.serverless".l10n())customRequestBidAccept"
            }
        case .getList:
            return "\("config.serverless".l10n())bookingList"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .createBooking, .updateCustomizeRequestStatus, .checkAvailability, .complaint:
            return .post
        case .getList, .getDetail:
            return .get
        case .updateBookingStatus:
            return .put
        }
    }
    
    public var sampleData: Data { return Data() }
    
    public var task: Task {
        switch self {
        case let .createBooking(request):
            return .requestJSONEncodable(request)
        case let .getDetail(id):
            return .requestParameters(parameters: ["id": id], encoding: URLEncoding.queryString)
        case let .updateBookingStatus(id, _):
            return .requestParameters(parameters: ["id": id], encoding: JSONEncoding.default)
        case let .checkAvailability(request):
            return .requestJSONEncodable(request)
        case let .updateCustomizeRequestStatus(id, artisanId, price, _):
            var params: [String : Any] = [:]
            
            params["bookingId"] = id
            
            if let artisanId = artisanId {
                params["artisanId"] = artisanId
            }

            if let price = price {
                params["price"] = price
            }

            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        case let .complaint(request):
            return .requestJSONEncodable(request)
        case let .getList(statuses, keyword, page, limit, timestamp):
            var params: [String : Any] = [:]
            
            params["page"] = page
            params["limit"] = limit
            
            if let keyword = keyword {
                params["search"] = keyword
            }
            
            if let statuses = statuses, !statuses.isEmpty {
                var bookingStatuses = statuses
                
                if let index = bookingStatuses.firstIndex(of: Booking.Status.canceled.rawValue) {
                    bookingStatuses.remove(at: index)
                    bookingStatuses.append(Booking.Status.canceledByArtisan.rawValue)
                    bookingStatuses.append(Booking.Status.canceledByCustomer.rawValue)
                } else if let _ = bookingStatuses.firstIndex(of: Booking.Status.complaint.rawValue) {
                    bookingStatuses.append(Booking.Status.settledForCustomer.rawValue)
                } else if let _ = bookingStatuses.firstIndex(of: Booking.Status.completed.rawValue) {
                    bookingStatuses.append(Booking.Status.settledForArtisan.rawValue)
                }
                
                params["statusIds"] = bookingStatuses
            }
            
            if let timestamp = timestamp {
                params["timestamp"] = timestamp * 1000
            }
            
            return .requestParameters(parameters: params, encoding: URLEncoding.queryString)
        }
    }
}


