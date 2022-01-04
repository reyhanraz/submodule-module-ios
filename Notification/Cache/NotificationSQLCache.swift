//
//  NotificationSQLCache.swift
//  Notification
//
//  Created by Fandy Gotama on 25/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class NotificationSQLCache: SQLCache<ListRequest, Notification> {
    
    public static func createTable(db: Database) throws {
        try db.create(table: Notification.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(Notification.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(Notification.Columns.userId.rawValue, .text).notNull()
            body.column(Notification.Columns.title.rawValue, .integer).notNull()
            body.column(Notification.Columns.body.rawValue, .integer).notNull()
            body.column(Notification.Columns.payloadType.rawValue, .text).notNull()
            body.column(Notification.Columns.payloadId.rawValue, .text)
            body.column(Notification.Columns.payloadURL.rawValue, .text)
            body.column(Notification.Columns.status.rawValue, .text).notNull()
            body.column(Notification.Columns.createdAt.rawValue, .integer).notNull()
            body.column(Notification.Columns.updatedAt.rawValue, .integer).notNull()
            body.column(Notification.Columns.icon.rawValue, .text)
            body.column(Paging.Columns.currentPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.limitPerPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.totalPage.rawValue, .integer).notNull()
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
    }
    
    public override func getList(request: ListRequest? = nil) -> [Notification] {
        do {
            let list = try dbQueue.read({ db -> [Notification] in
                if let request = getFilterQueries(request: request) {
                    return try Notification.filter(sql: request).fetchAll(db)
                } else {
                    return try Notification.fetchAll(db)
                }
            })
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public override func putList(models: [Notification]) {
        let timestamp = Date().timeIntervalSince1970
        
        do {
            try dbQueue.inTransaction { db in
                
                for notification in models {
                    try Notification(
                        id: notification.id,
                        userId: notification.userId,
                        title: notification.title,
                        body: notification.body,
                        payload: notification.payload,
                        status: notification.status,
                        createdAt: notification.createdAt,
                        updatedAt: notification.updatedAt,
                        icon: notification.icon,
                        paging: notification.paging,
                        timestamp: timestamp).insert(db)
                }
                
                return .commit
            }
        } catch {
            assertionFailure()
        }
    }
    
    public override func update(model: Notification) -> Bool {
        do {
            try dbQueue.write { db in
                try db.execute(sql: """
                    UPDATE \(Notification.databaseTableName) SET
                    \(Notification.Columns.status.rawValue) = ?
                    WHERE
                    \(Notification.Columns.id.rawValue) = ?
                    """, arguments: [model.status.rawValue,
                                     model.id])
            }
            
            return true
        } catch {
            assertionFailure()
        }
        
        return false
    }
    
    public override func getFilterQueries(request: ListRequest?) -> String? {
        guard let page = request?.page else { return nil }
        
        var filter: String?
        
        if page > 0 {
            filter = "\(Paging.Columns.currentPage) = \(page)"
        }
        
        return filter
    }
}



