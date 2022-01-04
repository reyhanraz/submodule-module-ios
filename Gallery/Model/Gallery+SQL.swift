//
//  Gallery+SQL.swift
//  Gallery
//
//  Created by Fandy Gotama on 22/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

extension Gallery: MultiTableRecord {
    public typealias R = ListRequest

    public var contentValues: [String : DatabaseValueConvertible?] {

        var params: [String : DatabaseValueConvertible?] = [
            Gallery.Columns.id.rawValue: id,
            Gallery.Columns.userId.rawValue: userId,
            Gallery.Columns.folder.rawValue: folder,
            Gallery.Columns.key.rawValue: key,
            Gallery.Columns.type.rawValue: type,
            Gallery.Columns.format.rawValue: format,
            Gallery.Columns.media.rawValue: media.url,
            Gallery.Columns.mediaServingURL.rawValue: media.servingURL,
            Gallery.Columns.createdAt.rawValue: createdAt.timeIntervalSince1970,
            Gallery.Columns.updatedAt.rawValue: createdAt.timeIntervalSince1970,
            CommonColumns.timestamp.rawValue: timestamp
        ]

        if let paging = paging {
            params[Paging.Columns.currentPage.rawValue] = paging.currentPage
            params[Paging.Columns.limitPerPage.rawValue] = paging.limitPerPage
            params[Paging.Columns.totalPage.rawValue] = paging.totalPage
        }

        return params
    }

    func insert(_ db: Database, tableName: String) throws {
        let columns = columnNamesAndKeys

        let statement = "INSERT INTO \(tableName) (\(columns.names)) VALUES (\(columns.keys))"

        try db.execute(sql: statement, arguments: StatementArguments(contentValues))
    }

    func update(_ db: Database, tableName: String) throws {
        let columns = columnNamesForUpdate

        let statement = "UPDATE \(tableName) SET \(columns) WHERE \(CommonColumns.id.rawValue) = :\(CommonColumns.id.rawValue)"

        try db.execute(sql: statement, arguments: StatementArguments(contentValues))
    }

    public static func delete(_ db: Database, model: Gallery, tableName: String) throws {
        try db.execute(sql: "DELETE FROM \(tableName) WHERE \(Gallery.Columns.id.rawValue) = ?", arguments: [model.id])
    }

    static func fetchAll(_ db: Database, request: R?, tableName: String) throws -> [Gallery] {
        let query = getQueryStatement(request: request, tableName: tableName)
        let order = getOrderStatement(request: request, tableName: tableName)

        let rows = try Row.fetchAll(db, sql:
        """
        SELECT * FROM \(tableName) \(query) \(order)
        """)

        return rows.map { row in

            let paging = Paging(
                currentPage: row[Paging.Columns.currentPage] ?? 1,
                limitPerPage: row[Paging.Columns.limitPerPage] ?? 1,
                totalPage: row[Paging.Columns.totalPage] ?? 1)

            let media: Media
            let mediaCoverURL: URL?

            if let gallery = row[Gallery.Columns.mediaServingURL] as? String, let galleryURL = URL(string: gallery) {
                mediaCoverURL = galleryURL
            } else {
                mediaCoverURL = nil
            }

            if let gallery = row[Gallery.Columns.media] as? String, let galleryURL = URL(string: gallery) {
                media = Media(url: galleryURL, servingURL: mediaCoverURL)
            } else {
                fatalError()
            }

            return Gallery(
                userId: row[Gallery.Columns.id],
                folder: row[Gallery.Columns.folder],
                key: row[Gallery.Columns.key],
                media: media,
                mediaCoverURL: mediaCoverURL,
                format: row[Gallery.Columns.format],
                type: row[Gallery.Columns.type],
                id: row[Gallery.Columns.id],
                uploadStatus: .success,
                createdAt: row[Gallery.Columns.createdAt],
                updatedAt: row[Gallery.Columns.updatedAt],
                paging: paging)

        }

    }

    public static func getQueryStatement(request: R?, tableName: String) -> String {
        var query = "WHERE \(tableName).\(CommonColumns._id.rawValue) != -1"

        if let request = request {
            if let id = request.id, id > 0 {
                query += " AND  \(tableName).\(Gallery.Columns.userId.rawValue) = \(id)"
            }

            if request.page > 0 && !request.ignorePaging {
                query += " AND \(Paging.Columns.currentPage.rawValue) = \(request.page)"
            }
        }

        return query
    }

    public static func getOrderStatement(request: R?, tableName: String) -> String {
        let order = "ORDER BY \(tableName).\(Paging.Columns.currentPage.rawValue) ASC, \(tableName).\(Gallery.Columns.id.rawValue) DESC"

        return order
    }
}

