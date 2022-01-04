//
//  CustomizeRequest.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 03/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB

public class CustomizeRequest: Codable, Pageable, FetchableRecord, PersistableRecord {
    public enum Status: Int, Codable {
        case open = 1
    }
    
    public let id: Int
    public let address: Address
    public let eventName: String
    public let start: Date
    public let totalPrice: Decimal
    public let createdAt: Date
    public let updatedAt: Date
    public let customer: User
    public let artisan: Artisan?
    public let notes: String?
    public let customizeRequestServices: [CustomizeRequestService]?
    
    public var status: CustomizeRequest.Status
    public var timestamp: TimeInterval?
    public var paging: Paging?
    
    public init(id: Int, status: CustomizeRequest.Status, eventName: String, start: Date, totalPrice: Decimal, createdAt: Date, updatedAt: Date, notes: String?, customer: User, artisan: Artisan?, address: Address, bookingServices: [CustomizeRequestService], paging: Paging?, timestamp: TimeInterval) {
        self.id = id
        self.status = status
        self.eventName = eventName
        self.start = start
        self.totalPrice = totalPrice
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.customer = customer
        self.artisan = artisan
        self.notes = notes
        self.address = address
        self.customizeRequestServices = bookingServices
        self.paging = paging
        self.timestamp = timestamp
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
        status = try container.decode(CustomizeRequest.Status.self, forKey: .status)
        eventName = try container.decode(String.self, forKey: .eventName)
        totalPrice = Decimal(string: decodedTotalPrice) ?? 0
        customer = try container.decode(User.self, forKey: .customer)
        address = try container.decode(Address.self, forKey: .address)
        
        customizeRequestServices = try container.decodeIfPresent([CustomizeRequestService].self, forKey: .customizeRequestServices)
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
        artisan = try container.decodeIfPresent(Artisan.self, forKey: .artisan)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case status = "statusId"
        case eventName
        case start
        case totalPrice
        case createdAt
        case updatedAt
        case customer
        case artisan
        case address
        case customizeRequestServices = "customRequestServices"
        case notes = "note"
        case timestamp
    }
    
    enum Columns: String, ColumnExpression {
        case id
        case status
        case eventName
        case start
        case totalPrice
        case createdAt
        case updatedAt
        case customer
        case artisan
        case address
        case notes
        case customizeRequestServices
    }
    
    public struct CustomizeRequestService: Codable, FetchableRecord, PersistableRecord {
        public let customRequestId: Int
        public let serviceId: Int
        public let title: String
        public let price: Decimal
        public let quantity: Int
        public let updatedAt: Date
        
        public init(customRequestId: Int, serviceId: Int, title: String, price: Decimal, quantity: Int, updatedAt: Date) {
            self.customRequestId = customRequestId
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
            customRequestId = try container.decode(Int.self, forKey: .customRequestId)
            serviceId = try container.decode(Int.self, forKey: .serviceId)
            title = try container.decode(String.self, forKey: .title)
            price = Decimal(string: decodedPrice) ?? 0
            quantity = try container.decode(Int.self, forKey: .quantity)
        }
        
        enum CodingKeys: String, CodingKey {
            case customRequestId = "bookingId"
            case serviceId = "serviceCategoryTypeId"
            case title
            case price
            case quantity
            case updatedAt
        }
        
        enum Columns: String, ColumnExpression {
            case customRequestId
            case serviceId
            case title
            case price
            case quantity
            case updatedAt
        }
    }
}

extension CustomizeRequest {
    public var serviceTypes: String? {
        return customizeRequestServices?.map { $0.title }.joined(separator: ", ")
    }
}

