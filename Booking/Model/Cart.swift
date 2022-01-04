//
//  Cart.swift
//  Booking
//
//  Created by Fandy Gotama on 29/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Foundation
import Platform
import GRDB

public class Cart: Codable, FetchableRecord, PersistableRecord {
    public let artisanId: Int
    public let name: String
    public let avatar: Media?
    
    public var items: [Item]
    public var timestamp: TimeInterval?

    private let avatarServingURL: URL?

    public init(artisanId: Int, name: String, avatar: Media?, avatarServingURL: URL?, items: [Item], timestamp: TimeInterval? = nil) {
        self.artisanId = artisanId
        self.name = name
        self.avatar = avatar
        self.avatarServingURL = avatarServingURL
        self.items = items
        self.timestamp = timestamp
    }
    
    public enum Columns: String, ColumnExpression {
        case artisanId
        case name
        case avatar
        case avatarServingURL = "avatarServiceUrl"
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decodedAvatar = try container.decodeIfPresent(URL.self, forKey: .avatar)
        
        artisanId = try container.decode(Int.self, forKey: .artisanId)
        name = try container.decode(String.self, forKey: .name)
        items = try container.decode([Item].self, forKey: .items)
        avatarServingURL = try container.decodeIfPresent(URL.self, forKey: .avatarServingURL)

        if let decodedAvatar = decodedAvatar {
            avatar = Media(url: decodedAvatar, servingURL: avatarServingURL)
        } else {
            avatar = nil
        }
        
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
    }
    
    public class Item: Codable, FetchableRecord, PersistableRecord {
        public static let databaseTableName = "cartItem"
        
        public let id: Int
        public let title: String
        public let description: String
        public let artisanId: Int
        public let serviceTypes: [ServiceType]
        public let serviceFee: Decimal
        
        public var notes: String?
        public var quantity: Int
        
        enum Columns: String, ColumnExpression {
            case id
            case title
            case description
            case serviceTypes
            case serviceFee
            case quantity
            case notes
        }
        
        public init(id: Int, title: String, description: String, artisanId: Int, serviceTypes: [ServiceType], serviceFee: Decimal, quantity: Int, notes: String?) {
            self.id = id
            self.title = title
            self.description = description
            self.artisanId = artisanId
            self.serviceTypes = serviceTypes
            self.serviceFee = serviceFee
            self.quantity = quantity
            self.notes = notes
        }
        
        public struct ServiceType: Codable, FetchableRecord, PersistableRecord {
            public static let databaseTableName = "cartServiceType"
            
            public let id: Int
            public let name: String
            
            public init(id: Int, name: String) {
                self.id = id
                self.name = name
            }
            
            enum Columns: String, ColumnExpression {
                case id
                case name
            }
        }
    }
}

extension Cart {
    public var totalServices: Int {
        return items.map { $0.quantity }.reduce(0, +)
    }
    
    public var totalFees: Decimal {
        return items.map { $0.serviceFee }.reduce(0, +)
    }
    
    public var grandTotal: Decimal {
        return items.map { Decimal($0.quantity) * $0.serviceFee }.reduce(0, +)
    }
    
    public var serviceTypes: String {
        return items.flatMap { $0.serviceTypes.compactMap { $0.name } }.joined(separator: ", ")
    }
    
    public var serviceIds: String {
        return items.map { $0.id }.map { String($0) }.joined(separator: ",")
    }
    
    public var services: [(serviceId: Int, quantity: Int)] {
        return items.flatMap { item in item.serviceTypes.compactMap { (serviceId: $0.id, quantity: item.quantity) } }
    }
    
    public var isHaveNotes: Bool {
        return !items.filter { $0.notes != nil }.isEmpty
    }
}

extension Cart.Item {
    public var types: String {
        return serviceTypes.map { $0.name }.joined(separator: ", ")
    }
}

extension Cart: CustomStringConvertible { }

extension Cart.Item: CustomStringConvertible { }

