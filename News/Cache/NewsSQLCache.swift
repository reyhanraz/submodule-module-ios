//
//  CategorySQLCache.swift
//  News
//
//  Created by Fandy Gotama on 27/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class NewsSQLCache: SQLCache<ListRequest, News> {

    public static func createTable(db: Database) throws {
        try db.create(table: News.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(News.CodingKeys.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(News.CodingKeys.title.rawValue, .text).notNull().collate(.localizedCaseInsensitiveCompare)
            body.column(News.CodingKeys.summary.rawValue, .text).notNull()
            body.column(News.CodingKeys.content.rawValue, .text)
            body.column(News.CodingKeys.createdAt.rawValue, .integer).notNull()
            body.column(News.CodingKeys.updatedAt.rawValue, .integer).notNull()
            body.column(News.CodingKeys.cover.rawValue, .text).notNull()
            body.column(News.CodingKeys.coverServingURL.rawValue, .text)
            body.column(News.CodingKeys.status.rawValue, .text).notNull()
            body.column(News.CodingKeys.authorId.rawValue, .integer).notNull()
            body.column(Paging.Columns.currentPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.limitPerPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.totalPage.rawValue, .integer).notNull()
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
    }

    public override func update(model: News) -> Bool {
        do {
            try dbQueue.write { db in
                let timestamp = Date().timeIntervalSince1970

                try db.execute(sql: """
                    UPDATE \(News.databaseTableName) SET
                    \(News.CodingKeys.title.rawValue) = ?,
                    \(News.CodingKeys.summary.rawValue) = ?,
                    \(News.CodingKeys.content.rawValue) = ?,
                    \(News.CodingKeys.createdAt.rawValue) = ?,
                    \(News.CodingKeys.updatedAt.rawValue) = ?,
                    \(News.CodingKeys.cover.rawValue) = ?,
                    \(News.CodingKeys.coverServingURL.rawValue) = ?,
                    \(News.CodingKeys.status.rawValue) = ?,
                    \(News.CodingKeys.authorId.rawValue) = ?,
                    \(CommonColumns.timestamp.rawValue) = ?
                    WHERE
                    \(News.CodingKeys.id.rawValue) = ?
                """, arguments: [model.title, model.summary,
                                 model.content,
                                 model.createdAt.timeIntervalSince1970,
                                 model.updatedAt.timeIntervalSince1970,
                                 model.cover.url,
                                 model.cover.servingURL,
                                 model.status.rawValue,
                                 model.authorId, model.id, timestamp])
            }

            return true
        } catch {
            assertionFailure()
        }

        return false
    }

    public override func getList(request: ListRequest? = nil) -> [News] {
        do {
            let list = try dbQueue.read({ db -> [News] in
                if let request = getFilterQueries(request: request) {
                    return try News.filter(sql: request).fetchAll(db)
                } else {
                    return try News.fetchAll(db)
                }

            })

            return list
        } catch {
            assertionFailure()
        }

        return []
    }

    public override func putList(models: [News]) {
        let timestamp = Date().timeIntervalSince1970

        do {
            try dbQueue.inTransaction { db in

                for news in models {
                    news.timestamp = timestamp

                    try news.insert(db)
                }

                return .commit
            }
        } catch {
            assertionFailure()
        }
    }

    public override func getFilterQueries(request: ListRequest?) -> String? {
        guard let request = request else { return nil }

        var filter: String?

        if request.page > 0 && !request.ignorePaging {
            filter = "\(Paging.Columns.currentPage.rawValue) = \(request.page)"
        }

        return filter
    }
}
