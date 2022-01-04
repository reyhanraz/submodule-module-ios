//
// Created by Fandy Gotama on 2019-07-27.
// Copyright (c) 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB

public class News: Codable, Pageable, FetchableRecord, PersistableRecord, CustomStringConvertible {
    public let id: Int
    public let title: String
    public let summary: String
    public let content: String?
    public let createdAt: Date
    public let updatedAt: Date
    public let cover: Media
    public let status: NewsStatus
    public let authorId: Int
    
    public var timestamp: TimeInterval?
    public var paging: Paging?

    private let coverServingURL: URL?

    enum CodingKeys: String, CodingKey, ColumnExpression {
        case id
        case title
        case summary
        case content
        case createdAt
        case updatedAt
        case cover = "coverUrl"
        case coverServingURL = "coverServingUrl"
        case status
        case authorId
        case timestamp
    }
    
    public enum NewsStatus: String, Codable {
        case published
    }
    
    public init(id: Int, title: String, summary: String, content: String?, createdAt: TimeInterval, updatedAt: TimeInterval, cover: URL, coverServingURL: URL?, status: NewsStatus, authorId: Int, paging: Paging? = nil, timestamp: TimeInterval?) {
        self.id = id
        self.title = title
        self.summary = summary
        self.content = content
        self.createdAt = Date(timeIntervalSince1970: createdAt)
        self.updatedAt = Date(timeIntervalSince1970: updatedAt)
        self.coverServingURL = coverServingURL
        self.cover = Media(url: cover, servingURL: coverServingURL)
        self.status = status
        self.authorId = authorId
        self.timestamp = timestamp
        self.paging = paging
    }
    
    public required init(row: Row) {
        id = row[CodingKeys.id]
        title = row[CodingKeys.title]
        summary = row[CodingKeys.summary]
        status = NewsStatus(rawValue: row[CodingKeys.status]) ?? .published
        authorId = row[CodingKeys.authorId]
        content = row[CodingKeys.content]
        coverServingURL = row[CodingKeys.coverServingURL]
        cover = Media(url: row[CodingKeys.cover], servingURL: coverServingURL)
        createdAt = Date(timeIntervalSince1970: row[CodingKeys.createdAt])
        updatedAt = Date(timeIntervalSince1970: row[CodingKeys.updatedAt])
        
        paging = Paging(currentPage: row[Paging.Columns.currentPage],
                        limitPerPage: row[Paging.Columns.limitPerPage],
                        totalPage: row[Paging.Columns.totalPage])
        
        timestamp = row[CommonColumns.timestamp]
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let decodedCreated = try container.decode(String.self, forKey: .createdAt)
        let decodedUpdated = try container.decode(String.self, forKey: .updatedAt)
        let decodedCover = try container.decode(URL.self, forKey: .cover)
        
        createdAt = decodedCreated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
        updatedAt = decodedUpdated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()

        coverServingURL = try container.decodeIfPresent(URL.self, forKey: .coverServingURL)

        cover = Media(url: decodedCover, servingURL: coverServingURL)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        summary = try container.decode(String.self, forKey: .summary)
        status = try container.decode(NewsStatus.self, forKey: .status)
        authorId = try container.decode(Int.self, forKey: .authorId)
        
        content = try container.decodeIfPresent(String.self, forKey: .content)
        
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
    }
    
    public func encode(to container: inout PersistenceContainer) {
        container[CodingKeys.id] = id
        container[CodingKeys.title] = title
        container[CodingKeys.summary] = summary
        container[CodingKeys.createdAt] = createdAt.timeIntervalSince1970
        container[CodingKeys.updatedAt] = updatedAt.timeIntervalSince1970
        container[CodingKeys.cover] = cover.url
        container[CodingKeys.coverServingURL] = cover.servingURL
        container[CodingKeys.status] = status.rawValue
        container[CodingKeys.authorId] = authorId
        container[Paging.Columns.currentPage] = paging?.currentPage ?? 1
        container[Paging.Columns.limitPerPage] = paging?.limitPerPage ?? PlatformConfig.defaultLimit
        container[Paging.Columns.totalPage] = paging?.totalPage ?? 1
        container[CommonColumns.timestamp] = timestamp
    }
}

