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
    
    public struct BookingStatus: Codable{
        public var id: Status
        public let title: String
        public let description: String
        
        public init(id: Int, title: String, description: String){
            self.id = Booking.Status(rawValue: id) ?? .booking
            self.title = title
            self.description = description
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = Booking.Status(rawValue: try container.decode(Int.self, forKey: .id)) ?? .booking
            title = try container.decode(String.self, forKey: .title)
            description = try container.decode(String.self, forKey: .description)
        }
        
        enum CodingKeys: String, CodingKey{
            case id
            case title
            case description
        }
        
        enum Columns: String, ColumnExpression{
            case id
            case title
            case description
        }
    }
    
    // MARK: - Invoice
    public struct Invoice: Codable {
        public let id: String?
        public let number: String?
        public let items: [Item]
        public let subtotal: Decimal
        
        public init(id: String?, number: String?, items: [Item], subtotal: Decimal){
            self.id = id
            self.number = number
            self.items = items
            self.subtotal = subtotal
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            number = try container.decode(String.self, forKey: .number)
            items = try container.decode([Item].self, forKey: .items)
            subtotal = Decimal(try container.decode(Int.self, forKey: .subtotal))
        }
        
        enum CodingKeys: String, CodingKey{
            case id
            case number
            case items
            case subtotal
        }
        
        enum Columns: String, ColumnExpression{
            case id
            case number
            case items
            case subtotal
        }
    }

    // MARK: - Item
    public struct Item: Codable {
        public let id: Int?
        public let service: Service?
        public let notes: String?
        
        public init(id: Int?, service: Service?, notes: String?){
            self.id = id
            self.service = service
            self.notes = notes
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(Int.self, forKey: .id)
            service = try container.decode(Service.self, forKey: .service)
            notes = try container.decodeIfPresent(String.self, forKey: .notes)
        }
        
        enum CodingKeys: String, CodingKey, ColumnExpression{
            case id
            case service
            case notes
        }
        
        enum Columns: String, ColumnExpression{
            case id
            case service
            case notes
        }
    }

    // MARK: - Service
    public struct Service: Codable {
        public let name: String?
        public let qty: Int?
        public let price: Decimal
        public let discount: Double?
        public let total: Decimal
        
        public init(name: String?, qty: Int?, price: Decimal, discount: Double?, total: Decimal){
            self.name = name
            self.qty = qty
            self.price = price
            self.discount = discount
            self.total = total
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let decodedPrice = try container.decode(Double.self, forKey: .price)
            let decodedTotal = try container.decode(Double.self, forKey: .total)

            name = try container.decode(String.self, forKey: .name)
            qty = try container.decode(Int.self, forKey: .qty)
            price = Decimal(decodedPrice)
            discount = try container.decode(Double.self, forKey: .discount)
            total = Decimal(decodedTotal)
        }
        
        enum CodingKeys: String, CodingKey {
            case name
            case qty
            case price
            case discount
            case total
        }
        
        enum Columns: String, ColumnExpression {
            case name
            case qty
            case price
            case discount
            case total
        }
    }
    
    public struct Artisan: Codable {
        public let id: String
        public let name: String
        public let avatar: URL?
        public let ratings: Double
        
        public init(id: String, name: String, avatar: URL?, ratings: Double){
            self.id = id
            self.name = name
            self.avatar = avatar
            self.ratings = ratings
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            id = try container.decode(String.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            avatar = try container.decode(URL.self, forKey: .avatar)
            ratings = try container.decode(Double.self, forKey: .ratings)
            
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case ratings
            case avatar
        }
        
        enum Columns: String, ColumnExpression {
            case id
            case name
            case ratings
            case avatar
        }
    }

    public let id: String
    public let eventName: String
    public let clientName: String
    public let status: String?
    public let bookingNumber: String

    public var bookingStatus: BookingStatus?
    public var eventAddress: EventAddress?
    public let eventDate: Date
    public let artisan: Artisan?
    public let invoice: Invoice
    public let platformFee: Decimal?
    public let discount: Double?
    public let paymentURL: String?
    public let totalDiscount: Double?
    public let grandTotal: Decimal
    public var paging: Paging?
    public let review: Review?
    public let complaint: Complaint?
    
    public init(id: String,
                eventName: String,
                clientName: String,
                status: String,
                bookingNumber: String,
                bookingStatus: Booking.BookingStatus,
                eventAddress: Booking.EventAddress,
                eventDate: Date,
                artisan: Booking.Artisan?,
                invoice: Booking.Invoice,
                platformFee: Decimal,
                discount: Double?,
                paymentURL: String?,
                totalDiscount: Double?,
                grantTotal: Decimal) {

        self.id = id
        self.eventName = eventName
        self.clientName = clientName
        self.status = status
        self.bookingNumber = bookingNumber
        self.bookingStatus = bookingStatus
        self.eventAddress = eventAddress
        self.eventDate = eventDate
        self.artisan = artisan
        self.invoice = invoice
        self.platformFee = platformFee
        self.discount = discount
        self.paymentURL = paymentURL
        self.totalDiscount = totalDiscount
        self.grandTotal = grantTotal
        self.review = nil // Review data only come from booking detail api, we didn't save it to cache
        self.complaint = nil
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decodedStart = try container.decode(String.self, forKey: .eventDate)
        let decodedTotalPrice = try container.decode(Double.self, forKey: .grandTotal)
        let decodedPlatformFee = try container.decodeIfPresent(Double.self, forKey: .platformFee)
        
        eventDate = decodedStart.toDate(format: "yyyy-MM-dd HH:mm:ss") ?? Date()
        
        id = try container.decode(String.self, forKey: .id)
        status = try container.decode(String.self, forKey: .status)
        bookingNumber = try container.decode(String.self, forKey: .bookingNumber)
        bookingStatus = try container.decodeIfPresent(BookingStatus.self, forKey: .bookingStatus)
        clientName = try container.decode(String.self, forKey: .clientName)
        eventName = try container.decode(String.self, forKey: .eventName)
        grandTotal = Decimal(decodedTotalPrice)
        eventAddress = try container.decodeIfPresent(EventAddress.self, forKey: .eventAddress)
        invoice = try container.decode(Invoice.self, forKey: .invoice)
        artisan = try container.decodeIfPresent(Artisan.self, forKey: .artisan)
        review = try container.decodeIfPresent(Review.self, forKey: .review)
        complaint = try container.decodeIfPresent(Complaint.self, forKey: .complaint)
        
        platformFee = Decimal(decodedPlatformFee ?? 0)
        discount = try container.decodeIfPresent(Double.self, forKey: .discount)
        paymentURL = try container.decodeIfPresent(String.self, forKey: .paymentURL)
        totalDiscount = try container.decodeIfPresent(Double.self, forKey: .totalDiscount)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case eventName = "event_name"
        case clientName = "client_name"
        case status
        case bookingStatus = "booking_status"
        case eventAddress = "event_address"
        case eventDate = "event_date"
        case artisan, invoice
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
        case eventName
        case clientName
        case status
        case bookingStatus
        case eventAddress
        case eventDate
        case artisan
        case invoice
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
    
    public struct EventAddress: Codable{
        public let name: String?
        public let latitude: Double?
        public let longitude: Double?
        public let addressNote: String?
        public let addressDetail: String?
        
        public init(name: String?, latitude: Double?, longitude: Double?, addressNote: String?, addressDetail: String?){
            self.name = name
            self.latitude = latitude
            self.longitude = longitude
            self.addressNote = addressNote
            self.addressDetail = addressDetail
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            name = try container.decodeIfPresent(String.self, forKey: .name)
            latitude = try container.decode(Double.self, forKey: .latitude)
            longitude = try container.decode(Double.self, forKey: .longitude)
            addressNote = try container.decode(String.self, forKey: .addressNote)
            addressDetail = try container.decode(String.self, forKey: .addressDetail)

        }

            enum CodingKeys: String, CodingKey {
                case name
                case latitude
                case longitude
                case addressNote = "notes"
                case addressDetail = "address_detail"
            }
    }
}

extension Booking {
    public var bookingCardServiceName: String{
        var name = ""
        name += invoice.items.first?.service?.name ?? ""
        if invoice.items.count > 1{
            name += " + \(invoice.items.count - 1) more"
        }
        return name
    }
    
    public var isContactable: Bool {
//        (status == .booking || status == .process || status == .accepted || status == .confirmed) && paymentStatus == .paid
        (bookingStatus?.id == .booking || bookingStatus?.id == .process || bookingStatus?.id == .accepted || bookingStatus?.id == .confirmed)
    }

    public var isCancelableByArtisan: Bool {
        bookingStatus?.id == .confirmed || bookingStatus?.id == .booking
    }

    public var isCancelable: Bool {
        alreadyBid || bookingStatus?.id == .booking || bookingStatus?.id == .confirmed || bookingStatus?.id == .open || bookingStatus?.id == .accepted
    }

    public var isCanceled: Bool {
        bookingStatus?.id == .canceledByArtisan || bookingStatus?.id == .canceledByCustomer || bookingStatus?.id == .canceledBySystem
    }

    public var bookingServiceTypes: String? {
//        bookingServices?.map { $0.title }.joined(separator: ", ")
        return ""
    }
    
    public var serviceIdAndQuantities: [(serviceId: Int, quantity: Int)]? {
        invoice.items.map{
            (serviceId: $0.id ?? -1, quantity: $0.service?.qty ?? -1)
        }
    }
    
    public var customizeRequestServiceTypes: String? {
//        customizeRequestServices?.map { $0.title }.joined(separator: ", ")
        return ""
    }
    
    public var alreadyBid: Bool {
        bookingStatus?.id == .bid
    }
    
    public var isEditable: Bool {
        bookingStatus?.id == .open
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
        guard let status = bookingStatus?.id else {return false}
        return (status == .open || status == .bid || status.isCanceled)
    }
    
    public var nextBookingStatus: Booking.Status {
        if bookingStatus?.id == .confirmed {
            return .process
        } else if bookingStatus?.id == .process {
            return .completed
        } else if bookingStatus?.id == .open {
            return .bid
        } else if bookingStatus?.id == .bid {
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
        return bookingStatus?.id == .confirmed || bookingStatus?.id == .process
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

public struct parseBooking: Codable{
    public let data: Booking

}

