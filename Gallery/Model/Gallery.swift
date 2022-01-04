//
//  Gallery.swift
//  Gallery
//
//  Created by Fandy Gotama on 13/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB

public class Gallery: Codable, Pageable, FetchableRecord, PersistableRecord, CustomStringConvertible {
    public let userId: Int
    public let folder: String
    public let key: String
    public let media: Media
    public let format: String
    public let type: String
    public let id: Int
    public let createdAt: Date
    public let updatedAt: Date
    
    public var timestamp: TimeInterval?
    public var paging: Paging?
    
    public var uploadStatus: UploadStatus
    public var checked = false

    private let mediaCoverURL: URL?

    enum Columns: String, CodingKey, ColumnExpression {
        case userId
        case folder
        case key
        case media = "url"
        case mediaServingURL = "imageServingUrl"
        case format
        case type
        case id
        case createdAt
        case updatedAt
    }
    
    public init(userId: Int = 0, folder: String = "", key: String = "", media: Media, mediaCoverURL: URL?, format: String = "", type: String = "", id: Int = 0, uploadStatus: UploadStatus, createdAt: Date = Date(), updatedAt: Date = Date(), paging: Paging? = nil) {
        self.userId = userId
        self.folder = folder
        self.key = key
        self.media = media
        self.mediaCoverURL = mediaCoverURL
        self.format = format
        self.type = type
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.paging = paging
        self.uploadStatus = uploadStatus
    }
    
    public required init(row: Row) {
        userId = row[Columns.userId]
        folder = row[Columns.folder]
        key = row[Columns.key]
        media = Media(url: row[Columns.media], servingURL: row[Columns.mediaServingURL])
        mediaCoverURL = row[Columns.mediaServingURL]
        format = row[Columns.format]
        type = row[Columns.type]
        id = row[Columns.id]
        createdAt = Date(timeIntervalSince1970: row[Columns.createdAt])
        updatedAt = Date(timeIntervalSince1970: row[Columns.updatedAt])
        paging = Paging(currentPage: row[Paging.Columns.currentPage],
                        limitPerPage: row[Paging.Columns.limitPerPage],
                        totalPage: row[Paging.Columns.totalPage])
        timestamp = row[CommonColumns.timestamp]
        uploadStatus = .success
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: Columns.self)
        
        let decodedCreated = try container.decode(String.self, forKey: .createdAt)
        let decodedUpdated = try container.decode(String.self, forKey: .updatedAt)
        let decodedURL = try container.decode(URL.self, forKey: .media)

        userId = try container.decode(Int.self, forKey: .userId)
        folder = try container.decode(String.self, forKey: .folder)
        key = try container.decode(String.self, forKey: .key)
        
        format = try container.decode(String.self, forKey: .format)
        type = try container.decode(String.self, forKey: .type)
        id = try container.decode(Int.self, forKey: .id)

        mediaCoverURL = try container.decodeIfPresent(URL.self, forKey: .mediaServingURL)

        createdAt = decodedCreated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
        updatedAt = decodedUpdated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()

        media = Media(url: URL(string: decodedURL.absoluteString.replacingOccurrences(of: "_original", with: ""))!, servingURL: mediaCoverURL)
        
        uploadStatus = .success
    }
    
    public func encode(to container: inout PersistenceContainer) {
        container[Columns.userId] = userId
        container[Columns.folder] = folder
        container[Columns.key] = key
        container[Columns.media] = media.url
        container[Columns.mediaServingURL] = media.servingURL
        container[Columns.format] = format
        container[Columns.type] = type
        container[Columns.id] = id
        container[Columns.createdAt] = createdAt.timeIntervalSince1970
        container[Columns.updatedAt] = updatedAt.timeIntervalSince1970
        container[Paging.Columns.currentPage] = paging?.currentPage ?? 1
        container[Paging.Columns.limitPerPage] = paging?.limitPerPage ?? PlatformConfig.defaultLimit
        container[Paging.Columns.totalPage] = paging?.totalPage ?? 1
        container[CommonColumns.timestamp] = timestamp
    }
}
