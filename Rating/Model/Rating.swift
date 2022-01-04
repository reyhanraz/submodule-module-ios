//
//  Rating.swift
//  Rating
//
//  Created by Fandy Gotama on 04/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB

public class Rating: Codable, Pageable, FetchableRecord, PersistableRecord {
    public let id: Int
    public let artisanId: Int
    public let comment: String?
    public let rating: Double
    public let updatedAt: Date
    public let customer: Customer

    public var paging: Paging?
    public var timestamp: TimeInterval?

    enum Columns: String, ColumnExpression {
        case id
        case artisanId
        case comment
        case rating
        case updatedAt
        case customer
    }

    public init(id: Int, artisanId: Int, comment: String?, rating: Double, updatedAt: Date, customer: Customer, paging: Paging?, timestamp: TimeInterval?) {
        self.id = id
        self.artisanId = artisanId
        self.comment = comment
        self.rating = rating
        self.updatedAt = updatedAt
        self.customer = customer
        self.timestamp = timestamp
    }

    public required init(row: Row) {
        self.id = row[Columns.id]
        self.artisanId = row[Columns.artisanId]
        self.comment = row[Columns.comment]
        self.rating = row[Columns.rating]
        self.updatedAt = Date(timeIntervalSince1970: row[Columns.updatedAt])
        self.timestamp = row[CommonColumns.timestamp]

        let avatar: Media?
        let avatarServingURL: URL?

        if let image = row[Customer.Columns.avatarServingURL] as? String, let url = URL(string: image) {
            avatarServingURL = url
        } else {
            avatarServingURL = nil
        }

        if let image = row[Customer.Columns.avatar] as? String, let url = URL(string: image) {
            avatar = Media(url: url, servingURL: avatarServingURL)
        } else {
            avatar = nil
        }

        let customer = Customer(
            id: row[Customer.Columns.id],
            name: row[Customer.Columns.name],
            avatar: avatar,
            avatarServingURL: avatarServingURL)

        self.customer = customer
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedUpdated = try container.decode(String.self, forKey: .updatedAt)

        updatedAt = decodedUpdated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()

        id = try container.decode(Int.self, forKey: .id)
        artisanId = try container.decode(Int.self, forKey: .artisanId)
        rating = try container.decode(Double.self, forKey: .rating)
        customer = try container.decode(Customer.self, forKey: .customer)

        comment = try container.decodeIfPresent(String.self, forKey: .comment)
        paging = try container.decodeIfPresent(Paging.self, forKey: .paging)
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
    }

    public struct Customer: Codable {
        public let id: Int
        public let name: String
        public let avatar: Media?

        private let avatarServingURL: URL?

        enum Columns: String, ColumnExpression {
            case id = "customerId"
            case name = "customerName"
            case avatar = "customerAvatar"
            case avatarServingURL = "customerAvatarServingURL"
        }

        enum CodingKeys: String, CodingKey {
            case id
            case name
            case avatar = "avatarUrl"
            case avatarServingURL = "avatarServingUrl"
        }

        public init(id: Int, name: String, avatar: Media?, avatarServingURL: URL?) {
            self.id = id
            self.name = name
            self.avatar = avatar
            self.avatarServingURL = avatarServingURL
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            let decodedAvatar = try container.decodeIfPresent(URL.self, forKey: .avatar)

            avatarServingURL = try container.decodeIfPresent(URL.self, forKey: .avatarServingURL)
            id = try container.decode(Int.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)

            if let decodedAvatar = decodedAvatar {
                avatar = Media(url: decodedAvatar, servingURL: avatarServingURL)
            } else {
                avatar = nil
            }

        }
    }

    public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.artisanId] = artisanId
        container[Columns.comment] = comment
        container[Columns.rating] = rating
        container[Columns.updatedAt] = updatedAt.timeIntervalSince1970
        container[CommonColumns.timestamp] = timestamp

        container[Customer.Columns.id] = customer.id
        container[Customer.Columns.name] = customer.name
        container[Customer.Columns.avatar] = customer.avatar?.url
        container[Customer.Columns.avatarServingURL] = customer.avatar?.servingURL

        if let paging = paging {
            container[Paging.Columns.currentPage] = paging.currentPage
            container[Paging.Columns.limitPerPage] = paging.limitPerPage
            container[Paging.Columns.totalPage] = paging.totalPage
        }
    }
}
