//
//  GallerySQLCache.swift
//  Gallery
//
//  Created by Fandy Gotama on 13/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class GallerySQLCache: Cache {

    public typealias R = NewListRequest
    public typealias T = Gallery
    
    private let _dbQueue: DatabaseQueue
    private let _tableName: String
    private let _expiredAfter: TimeInterval
    
    public init(dbQueue: DatabaseQueue, tableName: String, expiredAfter: TimeInterval = CacheExpiryDate.oneDay.rawValue) {
        _dbQueue = dbQueue
        _tableName = tableName
        _expiredAfter = expiredAfter
    }
    
    public static func createTable(db: Database, tableName: String) throws {
        try db.create(table: tableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(Gallery.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(Gallery.Columns.userId.rawValue, .integer).notNull()
            body.column(Gallery.Columns.folder.rawValue, .text).notNull()
            body.column(Gallery.Columns.key.rawValue, .text).notNull()
            body.column(Gallery.Columns.type.rawValue, .text).notNull()
            body.column(Gallery.Columns.format.rawValue, .text).notNull()
            body.column(Gallery.Columns.media.rawValue, .text).notNull()
            body.column(Gallery.Columns.mediaServingURL.rawValue, .text)
            body.column(Gallery.Columns.createdAt.rawValue, .integer).notNull()
            body.column(Gallery.Columns.updatedAt.rawValue, .integer).notNull()
            body.column(Paging.Columns.currentPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.limitPerPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.totalPage.rawValue, .integer).notNull()
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
    }

    public func get(request: R?) -> Gallery? {
        let list = getList(request: request)
        
        if let item = list.first {
            return item
        }
        
        return nil
    }
    
    public func getList(request: R?) -> [Gallery] {
        do {
            let list = try _dbQueue.read({ db in
                try Gallery.fetchAll(db, request: request, tableName: _tableName)
            })
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public func put(model: Gallery) {
        putList(models: [model])
    }
    
    public func putList(models: [Gallery]) {
        do {
            try _dbQueue.inTransaction { db in
                let timestamp = Date().timeIntervalSince1970
                
                for item in models {
                    item.timestamp = timestamp
                    
                    try item.insert(db, tableName: _tableName)
                }
                
                return .commit
            }
        } catch {
            assertionFailure()
        }
    }
    
    public func update(model: Gallery) -> Bool {
        return false
    }
    
    public func isCached(request: R?) -> Bool {
        do {
            let total = try _dbQueue.read { db in
                try Gallery.fetchCount(db, request: request, tableName: _tableName)
            }
            
            return total > 0
        } catch {
            return false
        }
    }
    
    public func isExpired(request: R?) -> Bool {
        do {
            let total = try _dbQueue.read { db in
                try Gallery.isExpired(db, request: request, tableName: _tableName, expiredAfter: _expiredAfter)
            }
            
            return total < 1
        } catch {
            return true
        }
    }
    
    public func remove(model: Gallery) {
       
        do {
            let _ = try _dbQueue.write { db in
                try Gallery.delete(db, model: model, tableName: _tableName)
            }
        } catch {
            assertionFailure()
        }
    }
    
    public func remove(request: R) {
        do {
            let _ = try _dbQueue.write { db in
                try Gallery.delete(db, request: request, tableName: _tableName)
            }
        } catch {
            assertionFailure()
        }
    }
    
    public func removeAll() {
        do {
            let _ = try _dbQueue.write { db in
                try Gallery.deleteAll(db, tableName: _tableName)
            }
        } catch {
            assertionFailure()
        }
    }
}

