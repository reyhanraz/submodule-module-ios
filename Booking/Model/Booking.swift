//
//  Booking.swift
//  Booking
//
//  Created by Fandy Gotama on 30/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB
import Category
import class Category.Category
import CoreLocation

public class Booking: Codable, Pageable, FetchableRecord, PersistableRecord {
    public enum Status: Int, Codable {
        case open = 1
        case paid = 2
        case waitingForPayment = 3
        case paymentExpired = 4
        case confirmed = 5
        case waitingForRefund = 6
        case refunded = 7
        case declined = 8
        case workInProgress = 9
        case waitingForConfirmation = 10
        case completed = 11
        case bid = 12
        case cancelBySystem = 13
        case rejected = 14
        case booked = 15
        case finished = 16
        case canceledByCustomer = 17
        case canceledByArtisan = 18
        case openIssue = 19
        
        public init(int: Int?) {
            switch int {
            case 1: self = .open
            case 2: self = .paid
            case 3: self = .waitingForPayment
            case 4: self = .paymentExpired
            case 5: self = .confirmed
            case 6: self = .waitingForRefund
            case 7: self = .refunded
            case 8: self = .declined
            case 9: self = .workInProgress
            case 10: self = .waitingForConfirmation
            case 11: self = .completed
            case 12: self = .bid
            case 13: self = .cancelBySystem
            case 14: self = .rejected
            case 15: self = .booked
            case 16: self = .finished
            case 17: self = .canceledByCustomer
            case 18: self = .canceledByArtisan
            case 19: self = .openIssue
            default: self = .waitingForConfirmation
            }
        }
        
        public var isCanceled: Bool {
            switch self {
            case .canceledByArtisan, .canceledByCustomer, .cancelBySystem:
                return true
            default:
                return false
            }
        }

        public var isCompleted: Bool {
            switch self {
            case .completed:
                return true
            default:
                return false
            }
        }

        public var isComplained: Bool {
            switch self {
            case .openIssue:
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
    
    public struct BookingStatus: Codable{
        public var id: Status
        public let title: String
        public let description: String
        public let status: String
        
        public init(id: Int, title: String, description: String, status: String){
            self.id = Booking.Status(int: id)
            self.title = title
            self.description = description
            self.status = status
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = Booking.Status(int: try container.decode(Int.self, forKey: .id))
            title = try container.decode(String.self, forKey: .title)
            description = try container.decode(String.self, forKey: .description)
            status = try container.decode(String.self, forKey: .status)
        }
        
        enum CodingKeys: String, CodingKey{
            case id
            case title
            case description
            case status
        }
        
        enum Columns: String, ColumnExpression{
            case id = "statusID"
            case title
            case description
            case status
        }
    }
    
    public struct StatusHistory: Codable {
        public let id: Int
        public let status: BookingStatus
        public let notes: String?
        public let createdAt: Date
        public let updatedAt: Date
        
        public init(id: Int, status: Booking.BookingStatus, notes: String?, createdAt: Date, updatedAt: Date){
            self.id = id
            self.status = status
            self.notes = notes
            self.createdAt = createdAt
            self.updatedAt = updatedAt
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            status = try container.decode(Booking.BookingStatus.self, forKey: .status)
            notes = try container.decodeIfPresent(String.self, forKey: .notes)
            createdAt = try container.decode(String.self, forKey: .createdAt).toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
            updatedAt = try container.decode(String.self, forKey: .updatedAt).toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()

        }
        
        enum CodingKeys: String, CodingKey{
            case id
            case status
            case notes
            case createdAt
            case updatedAt
        }
        
        enum Columns: String, ColumnExpression{
            case id
            case status
            case notes
            case createdAt
            case updatedAt
        }
    }

    // MARK: - Service
    public struct Service: Codable {
        public let id: String
        public let title: String
        public let notes: String
        public let quantity: Int
        public let price: Decimal
        public let discount: Double?
        public let category: Category?
        
        public var total: Decimal {
            return price * Decimal(quantity)
        }
        
        public init(id: String, title: String, notes: String, quantity: Int, price: Decimal, discount: Double?, category: Category?){
            self.id = id
            self.title = title
            self.notes = notes
            self.quantity = quantity
            self.price = price
            self.discount = discount
            self.category = category
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let decodedPrice = try container.decode(String.self, forKey: .price)
            
            id = try container.decode(String.self, forKey: .id)
            title = try container.decode(String.self, forKey: .title)
            notes = try container.decode(String.self, forKey: .notes)
            quantity = try container.decode(Int.self, forKey: .quantity)
            price = Decimal(string: decodedPrice) ?? 0
            discount = try container.decodeIfPresent(Double.self, forKey: .discount)
            category = try container.decode(Category.self, forKey: .category)
        }
        
        enum CodingKeys: String, CodingKey {
            case id
            case title
            case notes
            case quantity
            case price
            case discount
            case category
        }
        
        enum Columns: String, ColumnExpression {
            case id
            case title
            case notes
            case quantity
            case price
            case discount
            case categoryId
        }
    }


    public let id: String
    public let name: String
    public let eventName: String
    public var status: BookingStatus
    public let bookingNumber: String?
    public let services: [Service]

    public var venue: Venue
    public var histories: [Booking.StatusHistory]
    public let eventDate: Date
    public let artisan: Artisan?
    public let customer: NewProfile?
    public let platformFee: Decimal?
    public let discount: Double?
    public let paymentURL: String?
    public let totalDiscount: Double?
    public let grandTotal: Decimal
    public var paging: Paging?
    public let review: Review?
    public let complaint: Complaint?
    public var timeStamp: TimeInterval
    
    public init(id: String,
                name: String,
                eventName: String,
                status: Booking.BookingStatus,
                bookingNumber: String?,
                services: [Booking.Service],
                venue: Booking.Venue,
                histories: [Booking.StatusHistory],
                eventDate: Date,
                artisan: Artisan?,
                customer: NewProfile?,
                platformFee: Decimal,
                discount: Double?,
                paymentURL: String?,
                totalDiscount: Double?,
                grantTotal: Decimal,
                timestamp: TimeInterval) {

        self.id = id
        self.name = name
        self.eventName = eventName
        self.status = status
        self.bookingNumber = bookingNumber
        self.services = services
        self.venue = venue
        self.histories = histories
        self.eventDate = eventDate
        self.artisan = artisan
        self.customer = customer
        self.platformFee = platformFee
        self.discount = discount
        self.paymentURL = paymentURL
        self.totalDiscount = totalDiscount
        self.grandTotal = grantTotal
        self.review = nil // Review data only come from booking detail api, we didn't save it to cache
        self.complaint = nil
        self.timeStamp = timestamp
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decodedStart = try container.decode(String.self, forKey: .eventDate)
        let decodedTotalPrice = try container.decodeIfPresent(Double.self, forKey: .grandTotal)
        let decodedPlatformFee = try container.decodeIfPresent(Double.self, forKey: .platformFee)
        
        eventDate = decodedStart.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
        
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        status = try container.decode(Booking.BookingStatus.self, forKey: .status)
        bookingNumber = try container.decodeIfPresent(String.self, forKey: .bookingNumber)
        services = try container.decode([Booking.Service].self, forKey: .services)
        eventName = try container.decode(String.self, forKey: .eventName)
        grandTotal = Decimal(decodedTotalPrice ?? 0)
        venue = try container.decode(Venue.self, forKey: .venue)
        histories = try container.decode([Booking.StatusHistory].self, forKey: .histories)

        artisan = try container.decode(Artisan.self, forKey: .artisan)
        customer = try container.decode(NewProfile.self, forKey: .customer)
        review = try container.decodeIfPresent(Review.self, forKey: .review)
        complaint = try container.decodeIfPresent(Complaint.self, forKey: .complaint)
        
        platformFee = Decimal(decodedPlatformFee ?? 0)
        discount = try container.decodeIfPresent(Double.self, forKey: .discount)
        paymentURL = try container.decodeIfPresent(String.self, forKey: .paymentURL)
        totalDiscount = try container.decodeIfPresent(Double.self, forKey: .totalDiscount)
        timeStamp = Date().timeIntervalSince1970
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case eventName = "event_name"
        case status
        case services
        case venue
        case histories
        case eventDate = "event_date"
        case artisan
        case customer
        case platformFee = "platform_fee"
        case discount
        case paymentURL = "payment_url"
        case totalDiscount = "total_discount"
        case grandTotal = "grand_total"
        case review
        case complaint = "__bookingComplaint__"
        case paging
        case bookingNumber = "booking_number"
    }
    
    enum Columns: String, ColumnExpression {
        case id
        case name
        case eventName
        case statusID
        case statusTitle
        case statusDesc
        case statusStatus
        case services
        case histories
        case eventDate
        case artisan
        case platformFee
        case discount
        case paymentURL
        case totalDiscount
        case grandTotal
        case bookingNumber
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
    
    public struct Venue: Codable{

        public let id: String?
        public let venueName: String?
        public let latitude: Double
        public let longitude: Double
        public let notes: String?
        public let address: String?
        
        public init(id: String?, venueName: String?, latitude: Double, longitude: Double, notes: String?, address: String?){
            self.id = id
            self.venueName = venueName
            self.latitude = latitude
            self.longitude = longitude
            self.notes = notes
            self.address = address
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try container.decodeIfPresent(String.self, forKey: .id)
            venueName = try container.decodeIfPresent(String.self, forKey: .venueName)
            latitude = Double(try container.decode(String.self, forKey: .latitude)) ?? 0.0
            longitude = Double(try container.decode(String.self, forKey: .longitude)) ?? 0.0
            notes = try container.decodeIfPresent(String.self, forKey: .notes)
            address = try container.decode(String.self, forKey: .address)

        }

        enum CodingKeys: String, CodingKey {
            case id
            case venueName
            case latitude
            case longitude
            case notes
            case address
        }
    }
}

extension Booking {
    public var bookingCardServiceName: String{
        var name = ""
        name += services.first?.title ?? ""
        if services.count > 1{
            name += " + \(services.count - 1) more"
        }
        return name
    }
    
    public var venueCoordinates: CLLocationCoordinate2D{
        return CLLocationCoordinate2D(latitude: venue.latitude, longitude: venue.longitude)
    }
    
    public var isContactable: Bool {
//        (status == .booking || status == .process || status == .accepted || status == .confirmed) && paymentStatus == .paid
//        (bookingStatus.id == .booking || bookingStatus.id == .process || bookingStatus.id == .accepted || bookingStatus.id == .confirmed)
        true
    }

    public var isCancelableByArtisan: Bool {
        status.id == .confirmed || status.id == .booked
    }

    public var isCancelable: Bool {
        alreadyBid || status.id == .booked || status.id == .confirmed || status.id == .open || status.id == .confirmed
    }

    public var isCanceled: Bool {
        status.id == .canceledByArtisan || status.id == .canceledByCustomer || status.id == .cancelBySystem
    }

    public var bookingServiceTypes: String? {
        return services.map{ $0.category?.name ?? "" }.joined(separator: ", ")
    }
    
    public var serviceIdAndQuantities: [(serviceId: String, quantity: Int)]? {
        services.map{
            (serviceId: $0.id, quantity: $0.quantity)
        }
    }
    
    public var customizeRequestServiceTypes: String? {
//        customizeRequestServices?.map { $0.title }.joined(separator: ", ")
        return ""
    }
    
    public var alreadyBid: Bool {
        status.id == .bid
    }
    
    public var isEditable: Bool {
        status.id == .open
    }

//    public var showPayment: Bool {
//        !isPaid && !isCanceled
//    }

    public var serviceId: Int? {
        serviceIds?.first
    }

    public var serviceIds: [Int]? {
//        customizeRequestServices?.map { $0.serviceId }
        return nil
    }

//    public var serviceTypes: String? {
//        if let services = bookingServices, !services.isEmpty {
//            return bookingServiceTypes
//        }
//
//        return customizeRequestServiceTypes
//    }
    
    public var isRequestNotAccepted: Bool {
        let status = status.id
        return (status == .open || status == .bid || status.isCanceled)
    }
    
    public var nextBookingStatus: Booking.Status {
        if status.id == .confirmed {
            return .workInProgress
        } else if status.id == .workInProgress {
            return .completed
        } else if status.id == .open {
            return .bid
        } else if status.id == .bid {
            return .bid
        }
        
        return .confirmed
    }
    
//    public var revertBookingStatus: Status {
//        if bookingStatus?.id == .confirmed {
//            return hasBid ? .accepted : .booking
//        } else if bookingStatus?.id == .completed {
//            return .process
//        } else if bookingStatus?.id == .bid {
//            return .open
//        } else if bookingStatus?.id == .canceledByArtisan || bookingStatus?.id == .bid {
//            return .bid
//        }
//
//        return .confirmed
//    }
    
//    public var nextBookingAction: String {
//
//        if bookingStatus?.id == .confirmed {
//            return "process".l10n()
//        } else if bookingStatus?.id == .process {
//            return "complete".l10n()
//        } else if bookingStatus?.id == .completed {
//            return "completed".l10n()
//        } else if bookingStatus?.id == .open {
//            return "bid".l10n()
//        } else if bookingStatus?.id == .bid {
//            return hasBid ? "cancel".l10n() : "bid".l10n()
//        }
//
//        return "confirm".l10n()
//    }
//
//    public var bookingStatus: String {
//        if bookingStatus?.id == .bid {
//            return hasBid ? "bid_by_you".l10n() : "bid".l10n()
//        } else {
//            return Booking.bookingStatusDescription(status: bookingStatus?.id)
//        }
//    }
    
    // Artisan can only process booking on the same date max 2 hours before event start and 12 hours after event start.
    public var isAbleToProcess: Bool {
        return Calendar.current.isDateInToday(eventDate) &&
        eventDate.timeIntervalSince1970 - Date().timeIntervalSince1970 <= 7200 &&
            Date().timeIntervalSince1970 - eventDate.timeIntervalSince1970 <= 43200
    }

//    public var isPaid: Bool {
//        paymentStatus == .paid || paymentStatus == .disbursed || paymentStatus == .refunded || paymentStatus == .toRefund
//    }

    public var isExpired: Bool {
        return Date().timeIntervalSince1970 - eventDate.timeIntervalSince1970 >= 43200
    }
    
    public var showDirectionLink: Bool {
        return status.id == .confirmed || status.id == .workInProgress
    }

//    public var paymentStatusName: String {
//        if paymentStatus == .paid {
//            return "paid".l10n()
//        } else if paymentStatus == .pending {
//            return "pending".l10n()
//        } else if paymentStatus == .disbursed {
//            return "disbursed".l10n()
//        } else if paymentStatus == .refunded {
//            return "refunded".l10n()
//        } else if paymentStatus == .toRefund {
//            return "ready_for_refund".l10n()
//        }
//
//        return "unpaid".l10n()
//    }
//
//    public var bookingStatusDetailed: String {
//        if bookingStatus?.id == .accepted {
//            return "booking_accepted_detailed".l10n()
//        } else if bookingStatus?.id == .confirmed {
//            return "booking_confirmed_detailed".l10n()
//        } else if bookingStatus?.id == .process {
//            return "booking_processed_detailed".l10n()
//        } else if bookingStatus?.id == .completed || bookingStatus?.id == .settledForArtisan {
//            return "booking_completed_detailed".l10n()
//        } else if bookingStatus?.id == .canceledByArtisan {
//            return "booking_canceled_by_artisan_detailed".l10n()
//        } else if bookingStatus?.id == .canceledByCustomer {
//            return "booking_canceled_by_customer_detailed".l10n()
//        } else if bookingStatus?.id == .canceledBySystem {
//            return "booking_canceled_by_system_detailed".l10n()
//        } else if bookingStatus?.id == .booking {
//            return "booking_waiting_detailed".l10n()
//        } else if bookingStatus?.id == .bid {
//            return hasBid ? "booking_bid_by_self_detailed".l10n() : "booking_bid_by_other_detailed".l10n()
//        } else if bookingStatus?.id == .complaint || bookingStatus?.id == .settledForCustomer {
//            return "booking_complained_detailed".l10n()
//        }
//
//        return "booking_open_detailed".l10n()
//    }
    
    public var hasReview: Bool {
        review != nil
    }
    
    static func bookingStatusDescription(status: Booking.Status) -> String {
        if status == .confirmed {
            return "accepted".l10n()
        } else if status == .confirmed {
            return "confirmed".l10n()
        } else if status == .workInProgress {
            return "processed".l10n()
        } else if status.isCompleted {
            return "completed".l10n()
        } else if status.isCanceled {
            return "canceled".l10n()
        } else if status == .booked {
            return "booking".l10n()
        } else if status == .bid {
            return "bid".l10n()
        } else if status.isComplained {
            return "complaint".l10n()
        }
        
        return "open".l10n()
    }
}

public struct parseBooking: Codable{
    public let data: Booking

}

