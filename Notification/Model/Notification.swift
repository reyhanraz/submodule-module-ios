//
//  Notification.swift
//  Notification
//
//  Created by Fandy Gotama on 25/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class Notification: Codable, FetchableRecord, PersistableRecord {
    public enum Status: String, Codable {
        case read = "read"
        case unread = "unread"
    }
    
    public let id: Int
    public let userId: Int
    public let title: String
    public let body: String
    public let payload: Payload
    public let createdAt: Date
    public let updatedAt: Date
    public let icon: URL?
    public var status: Notification.Status
    public var timestamp: TimeInterval?
    public var paging: Paging?
    
    public struct Payload: Codable {
        public let data: Data
        
        public struct Data: Codable {
            public let type: String
            public let id: String?
            public let url: URL?
        }
    }
    
    init(id: Int, userId: Int, title: String, body: String, payload: Payload, status: Notification.Status, createdAt: Date, updatedAt: Date, icon: URL?, paging: Paging?, timestamp: TimeInterval) {
        self.id = id
        self.userId = userId
        self.title = title
        self.body = body
        self.payload = payload
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.icon = icon
        self.paging = paging
        self.timestamp = timestamp
    }
    
    public required init(row: Row) {
        let url: URL?
        
        if let payloadURL = row[Columns.payloadURL] as? String {
            url = URL(string: payloadURL)
        } else {
            url = nil
        }
        
        id = row[Columns.id]
        userId = row[Columns.userId]
        title = row[Columns.title]
        body = row[Columns.body]
        payload = Payload(data: Payload.Data(type: row[Columns.payloadType], id: row[Columns.payloadId], url: url))
        status = Notification.Status(rawValue: row[Columns.status]) ?? .unread
        createdAt = Date(timeIntervalSince1970: row[Columns.createdAt])
        updatedAt = Date(timeIntervalSince1970: row[Columns.updatedAt])
        icon = row[Columns.icon]
        
        paging = Paging(currentPage: row[Paging.Columns.currentPage],
                        limitPerPage: row[Paging.Columns.limitPerPage],
                        totalPage: row[Paging.Columns.totalPage])
        timestamp = row[CommonColumns.timestamp]
       
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let decodedCreated = try container.decode(String.self, forKey: .createdAt)
        let decodedUpdated = try container.decode(String.self, forKey: .updatedAt)
        
        id = try container.decode(Int.self, forKey: .id)
        userId = try container.decode(Int.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        body = try container.decode(String.self, forKey: .body)
        payload = try container.decode(Payload.self, forKey: .payload)
        status = try container.decode(Notification.Status.self, forKey: .status)
        
        icon = try container.decodeIfPresent(URL.self, forKey: .icon)
        
        createdAt = decodedCreated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
        updatedAt = decodedUpdated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
    }
    
    public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.userId] = userId
        container[Columns.title] = title
        container[Columns.body] = body
        container[Columns.payloadId] = payload.data.id
        container[Columns.payloadType] = payload.data.type
        container[Columns.payloadURL] = payload.data.url
        container[Columns.status] = status.rawValue
        container[Columns.createdAt] = createdAt.timeIntervalSince1970
        container[Columns.updatedAt] = updatedAt.timeIntervalSince1970
        container[Columns.icon] = icon
        container[Paging.Columns.currentPage] = paging?.currentPage ?? 1
        container[Paging.Columns.limitPerPage] = paging?.limitPerPage ?? PlatformConfig.defaultLimit
        container[Paging.Columns.totalPage] = paging?.totalPage ?? 1
        container[CommonColumns.timestamp] = timestamp
    }
    
    enum Columns: String, ColumnExpression {
        case id
        case userId
        case title
        case body
        case payloadType
        case payloadId
        case payloadURL
        case status
        case createdAt
        case updatedAt
        case icon
    }
}

extension Notification {
    public var bookingId: Int? {
        if isBooking, let bookingId = payload.data.id, let id = Int(bookingId) {
            return id
        }
        
        return nil
    }
    
    public var isBooking: Bool {
        return payload.data.type == "booking" || payload.data.type == "customRequest"
    }
}
