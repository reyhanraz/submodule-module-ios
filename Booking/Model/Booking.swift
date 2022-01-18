//
//  Booking.swift
//  Booking
//
//  Created by Fandy Gotama on 30/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB

public class Booking: Codable, Pageable, FetchableRecord, PersistableRecord {
    public enum Status: Int, Codable {
        case open = 1
        case booking = 2
        case confirmed = 3
        case bid = 4
        case accepted = 5
        case process = 6
        case completed = 7
        case canceledByArtisan = 8
        case canceledByCustomer = 9
        case canceledBySystem = 10
        case complaint = 11
        case settledForArtisan = 12
        case settledForCustomer = 13
        case canceled = 99
        
        public var color: UIColor {
            get {
                switch self {
                case .accepted, .confirmed, .completed, .process, .settledForArtisan:
                    return UIColor(red: 128/255, green: 169/255, blue: 91/255, alpha: 1)
                case .open, .booking:
                    return UIColor.BeautyBell.accent
                case .bid:
                    return UIColor(red: 243/255, green: 206/255, blue: 97/255, alpha: 1)
                case .canceledByCustomer, .canceledByArtisan, .canceledBySystem, .complaint, .settledForCustomer, .canceled:
                    return UIColor.BeautyBell.gray500
                }
            }
        }
        
        public var isCanceled: Bool {
            switch self {
            case .canceledByArtisan, .canceledByCustomer, .canceledBySystem, .canceled:
                return true
            default:
                return false
            }
        }

        public var isCompleted: Bool {
            switch self {
            case .completed, .settledForArtisan:
                return true
            default:
                return false
            }
        }

        public var isComplained: Bool {
            switch self {
            case .complaint, .settledForCustomer:
                return true
            default:
                return false
            }
        }
    }

    public enum PaymentStatus: Int, Codable {
        case pending = 1
        case paid = 2
        case disbursed = 3
        case refunded = 4
        case toRefund = 6
        case unpaid = 0
    }

    public let id: Int
    public let invoice: String
    public let eventName: String
    public let start: Date
    public let totalPrice: Decimal
    public let createdAt: Date
    public let updatedAt: Date
    public let artisan: Artisan?
    public let customer: User
    public let bookingAddress: BookingAddress?
    public let notes: String?
    public let bookingServices: [BookingService]?
    public let customizeRequestServices: [CustomizeRequestService]?
    public let hasBid: Bool
    public var paymentStatus: PaymentStatus
    public var status: Booking.Status
    public var timestamp: TimeInterval?
    public var paging: Paging?
    
    let isCustom: Bool
    public let review: Review?
    public let complaint: Complaint?
    
    public init(id: Int,
                invoice: String,
                status: Booking.Status,
                eventName: String,
                start: Date,
                totalPrice: Decimal,
                createdAt: Date,
                updatedAt: Date,
                artisan: Artisan?,
                customer: User,
                bookingAddress: BookingAddress?,
                notes: String?,
                bookingServices: [BookingService]?,
                customizeRequestServices: [CustomizeRequestService]?,
                paging: Paging?,
                hasBid: Bool,
                isCustom: Bool,
                paymentStatus: PaymentStatus,
                timestamp: TimeInterval) {

        self.id = id
        self.invoice = invoice
        self.status = status
        self.eventName = eventName
        self.start = start
        self.totalPrice = totalPrice
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.artisan = artisan
        self.customer = customer
        self.bookingAddress = bookingAddress
        self.bookingServices = bookingServices
        self.customizeRequestServices = customizeRequestServices
        self.notes = notes
        self.paging = paging
        self.timestamp = timestamp
        self.hasBid = hasBid
        self.isCustom = isCustom
        self.paymentStatus = paymentStatus
        self.review = nil // Review data only come from booking detail api, we didn't save it to cache
        self.complaint = nil
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decodedStart = try container.decode(String.self, forKey: .start)
        let decodedCreated = try container.decode(String.self, forKey: .createdAt)
        let decodedUpdated = try container.decode(String.self, forKey: .updatedAt)
        let decodedTotalPrice = try container.decode(String.self, forKey: .totalPrice)
        
        start = decodedStart.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
        createdAt = decodedCreated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
        updatedAt = decodedUpdated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
        
        id = try container.decode(Int.self, forKey: .id)
        status = try container.decode(Booking.Status.self, forKey: .status)
        eventName = try container.decode(String.self, forKey: .eventName)
        totalPrice = Decimal(string: decodedTotalPrice) ?? 0
        customer = try container.decode(User.self, forKey: .customer)
        bookingAddress = try container.decode(BookingAddress.self, forKey: .bookingAddress)
        invoice = try container.decode(String.self, forKey: .invoice)
        
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        bookingServices = try container.decodeIfPresent([BookingService].self, forKey: .bookingServices)
        customizeRequestServices = try container.decodeIfPresent([CustomizeRequestService].self, forKey: .customizeRequestServices)
        artisan = try container.decodeIfPresent(Artisan.self, forKey: .artisan)
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
        hasBid = try container.decodeIfPresent(Bool.self, forKey: .hasBid) ?? false
        isCustom = try container.decodeIfPresent(Bool.self, forKey: .isCustom) ?? false
        review = try container.decodeIfPresent(Review.self, forKey: .review)
        complaint = try container.decodeIfPresent(Complaint.self, forKey: .complaint)

        paymentStatus = try container.decodeIfPresent(Booking.PaymentStatus.self, forKey: .paymentStatus) ?? .unpaid
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case status = "statusId"
        case eventName
        case start
        case totalPrice
        case createdAt
        case updatedAt
        case artisan
        case customer
        case bookingAddress
        case bookingServices
        case customizeRequestServices = "customRequestServices"
        case notes = "note"
        case timestamp
        case hasBid
        case isCustom
        case invoice
        case review
        case complaint = "__bookingComplaint__"
        case paymentStatus = "paymentStatusId"
    }
    
    enum Columns: String, ColumnExpression {
        case id
        case status
        case eventName
        case start
        case totalPrice
        case createdAt
        case updatedAt
        case artisan
        case customer
        case bookingAddress
        case notes
        case bookingServices
        case hasBid
        case isCustom
        case invoice
        case hasReview
        case paymentStatus
    }
    
    public struct Review: Codable {
        let bookingId: Int
        let id: Int
        let artisanId: Int
        let customerId: Int
        let comment: String
        let rating: Int
    }
    
    public struct Complaint: Codable {
        let id: Int
        let bookingId: Int
        let artisanId: Int
        let customerId: Int
        let statusId: Int
        let complaint: String
    }
    
    public struct BookingAddress: Codable{
        public let id: Int?
        public let name: String?
        public let latitude: String?
        public let longitude: String?
        public let addressNote: String?
        public let bookingID: Int?
        public let address: String?

            enum CodingKeys: String, CodingKey {
                case id
                case name
                case latitude
                case longitude
                case addressNote
                case bookingID = "bookingId"
                case address
            }
    }
    
    public struct BookingService: Codable, FetchableRecord, PersistableRecord {
        public let bookingId: Int
        public let serviceId: Int
        public let title: String
        public let price: Decimal
        public let quantity: Int
        public let notes: String?
        public let updatedAt: Date
        
        public init(bookingId: Int,
                    serviceId: Int,
                    title: String,
                    price: Decimal,
                    quantity: Int,
                    notes: String?,
                    updatedAt: Date) {
            self.bookingId = bookingId
            self.serviceId = serviceId
            self.title = title
            self.price = price
            self.quantity = quantity
            self.notes = notes
            self.updatedAt = updatedAt
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let decodedUpdated = try container.decode(String.self, forKey: .updatedAt)
            let decodedPrice = try container.decode(String.self, forKey: .price)
            
            updatedAt = decodedUpdated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
            bookingId = try container.decode(Int.self, forKey: .bookingId)
            serviceId = try container.decode(Int.self, forKey: .serviceId)
            title = try container.decode(String.self, forKey: .title)
            price = Decimal(string: decodedPrice) ?? 0
            quantity = try container.decode(Int.self, forKey: .quantity)
            notes = try container.decodeIfPresent(String.self, forKey: .notes)
        }
        
        enum CodingKeys: String, CodingKey {
            case bookingId
            case serviceId
            case title
            case price
            case quantity
            case notes = "note"
            case updatedAt
        }
        
        enum Columns: String, ColumnExpression {
            case bookingId
            case serviceId
            case title
            case price
            case quantity
            case notes
            case updatedAt
        }
    }
    
    public struct CustomizeRequestService: Codable, FetchableRecord, PersistableRecord {
        public let bookingId: Int
        public let serviceId: Int
        public let title: String
        public let price: Decimal
        public let quantity: Int
        public let updatedAt: Date
        
        public init(bookingId: Int, serviceId: Int, title: String, price: Decimal, quantity: Int, updatedAt: Date) {
            self.bookingId = bookingId
            self.serviceId = serviceId
            self.title = title
            self.price = price
            self.quantity = quantity
            self.updatedAt = updatedAt
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let decodedUpdated = try container.decode(String.self, forKey: .updatedAt)
            let decodedPrice = try container.decode(String.self, forKey: .price)
            
            updatedAt = decodedUpdated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
            bookingId = try container.decode(Int.self, forKey: .bookingId)
            serviceId = try container.decode(Int.self, forKey: .serviceId)
            title = try container.decode(String.self, forKey: .title)
            price = Decimal(string: decodedPrice) ?? 0
            quantity = try container.decode(Int.self, forKey: .quantity)
        }
        
        enum CodingKeys: String, CodingKey {
            case bookingId
            case serviceId = "serviceCategoryTypeId"
            case title
            case price
            case quantity
            case updatedAt
        }
        
        enum Columns: String, ColumnExpression {
            case bookingId
            case serviceId
            case title
            case price
            case quantity
            case updatedAt
        }
    }
}

extension Booking {
    public var isContactable: Bool {
        (status == .booking || status == .process || status == .accepted || status == .confirmed) && paymentStatus == .paid
    }

    public var isCancelableByArtisan: Bool {
        status == .confirmed || status == .booking
    }

    public var isCancelable: Bool {
        alreadyBid || status == .booking || status == .confirmed || status == .open || status == .accepted
    }

    public var isCanceled: Bool {
        status == .canceledByArtisan || status == .canceledByCustomer || status == .canceledBySystem
    }

    public var bookingServiceTypes: String? {
        bookingServices?.map { $0.title }.joined(separator: ", ")
    }
    
    public var serviceIdAndQuantities: [(serviceId: Int, quantity: Int)]? {
        bookingServices?.map { (serviceId: $0.serviceId, quantity: $0.quantity) }
    }
    
    public var customizeRequestServiceTypes: String? {
        customizeRequestServices?.map { $0.title }.joined(separator: ", ")
    }
    
    public var alreadyBid: Bool {
        status == .bid && hasBid
    }
    
    public var isEditable: Bool {
        isCustom && status == .open
    }

    public var showPayment: Bool {
        !isPaid && !isCustom && !isCanceled
    }

    public var serviceId: Int? {
        serviceIds?.first
    }

    public var serviceIds: [Int]? {
        customizeRequestServices?.map { $0.serviceId }
    }

    public var serviceTypes: String? {
        if let services = bookingServices, !services.isEmpty {
            return bookingServiceTypes
        }
        
        return customizeRequestServiceTypes
    }
    
    public var isRequestNotAccepted: Bool {
        isCustom && (status == .open || status == .bid || status.isCanceled)
    }
    
    public var nextBookingStatus: Booking.Status {
        if status == .confirmed {
            return .process
        } else if status == .process {
            return .completed
        } else if status == .open {
            return .bid
        } else if status == .bid {
            return hasBid ? .canceledByArtisan : .bid
        }
        
        return .confirmed
    }
    
    public var revertBookingStatus: Booking.Status {
        if status == .confirmed {
            return hasBid ? .accepted : .booking
        } else if status == .completed {
            return .process
        } else if status == .bid {
            return .open
        } else if status == .canceledByArtisan || status == .bid {
            return .bid
        }
        
        return .confirmed
    }
    
    public var nextBookingAction: String {
        
        if status == .confirmed {
            return "process".l10n()
        } else if status == .process {
            return "complete".l10n()
        } else if status == .completed {
            return "completed".l10n()
        } else if status == .open {
            return "bid".l10n()
        } else if status == .bid {
            return hasBid ? "cancel".l10n() : "bid".l10n()
        }
        
        return "confirm".l10n()
    }

    public var bookingStatus: String {
        if status == .bid {
            return hasBid ? "bid_by_you".l10n() : "bid".l10n()
        } else {
            return Booking.bookingStatusDescription(status: status)
        }
    }
    
    // Artisan can only process booking on the same date max 2 hours before event start and 12 hours after event start.
    public var isAbleToProcess: Bool {
        Calendar.current.isDateInToday(start) &&
            start.timeIntervalSince1970 - Date().timeIntervalSince1970 <= 7200 &&
            Date().timeIntervalSince1970 - start.timeIntervalSince1970 <= 43200
    }

    public var isPaid: Bool {
        paymentStatus == .paid || paymentStatus == .disbursed || paymentStatus == .refunded || paymentStatus == .toRefund
    }

    public var isExpired: Bool {
        Date().timeIntervalSince1970 - start.timeIntervalSince1970 >= 43200
    }
    
    public var showDirectionLink: Bool {
        if bookingAddress != nil{
            return status == .confirmed || status == .process
        }
        return false
    }

    public var paymentStatusName: String {
        if paymentStatus == .paid {
            return "paid".l10n()
        } else if paymentStatus == .pending {
            return "pending".l10n()
        } else if paymentStatus == .disbursed {
            return "disbursed".l10n()
        } else if paymentStatus == .refunded {
            return "refunded".l10n()
        } else if paymentStatus == .toRefund {
            return "ready_for_refund".l10n()
        }

        return "unpaid".l10n()
    }

    public var bookingStatusDetailed: String {
        if status == .accepted {
            return "booking_accepted_detailed".l10n()
        } else if status == .confirmed {
            return "booking_confirmed_detailed".l10n()
        } else if status == .process {
            return "booking_processed_detailed".l10n()
        } else if status == .completed || status == .settledForArtisan {
            return "booking_completed_detailed".l10n()
        } else if status == .canceledByArtisan {
            return "booking_canceled_by_artisan_detailed".l10n()
        } else if status == .canceledByCustomer {
            return "booking_canceled_by_customer_detailed".l10n()
        } else if status == .canceledBySystem {
            return "booking_canceled_by_system_detailed".l10n()
        } else if status == .booking {
            return "booking_waiting_detailed".l10n()
        } else if status == .bid {
            return hasBid ? "booking_bid_by_self_detailed".l10n() : "booking_bid_by_other_detailed".l10n()
        } else if status == .complaint || status == .settledForCustomer {
            return "booking_complained_detailed".l10n()
        }
        
        return "booking_open_detailed".l10n()
    }
    
    public var hasReview: Bool {
        review != nil
    }
    
    static func bookingStatusDescription(status: Booking.Status) -> String {
        if status == .accepted {
            return "accepted".l10n()
        } else if status == .confirmed {
            return "confirmed".l10n()
        } else if status == .process {
            return "processed".l10n()
        } else if status.isCompleted {
            return "completed".l10n()
        } else if status.isCanceled {
            return "canceled".l10n()
        } else if status == .booking {
            return "booking".l10n()
        } else if status == .bid {
            return "bid".l10n()
        } else if status.isComplained {
            return "complaint".l10n()
        }
        
        return "open".l10n()
    }
}

