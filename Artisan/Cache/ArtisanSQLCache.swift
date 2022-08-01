//
//  ArtisanSQLCache.swift
//  Artisan
//
//  Created by Fandy Gotama on 07/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform
import ServiceWrapper

public class ArtisanSQLCache: Cache {
    
    public typealias R = ArtisanFilter
    public typealias T = Artisan
    
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
            body.column(Artisan.Columns.id.rawValue, .text).notNull().unique(onConflict: .replace)
            body.column(Artisan.Columns.email.rawValue, .text)
            body.column(Artisan.Columns.name.rawValue, .text)
            body.column(Artisan.Columns.phoneNumber.rawValue, .text)
            body.column(Artisan.Columns.username.rawValue, .text)
            body.column(Artisan.Columns.facebookID.rawValue, .text)
            body.column(Artisan.Columns.googleID.rawValue, .text)
            body.column(Artisan.Columns.appleID.rawValue, .text)
            body.column(Artisan.Columns.metadata.rawValue, .blob)
            body.column(Artisan.Columns.favorite.rawValue, .integer)
            body.column(Artisan.Columns.jobDone.rawValue, .integer)
            body.column(Artisan.Columns.rating.rawValue, .double)
            body.column(Artisan.Columns.category.rawValue, .blob)
            body.column(Artisan.Columns.avatar.rawValue, .blob)
            body.column(Artisan.Columns.status.rawValue, .text)
            body.column(Artisan.Columns.created_at.rawValue, .date)
            body.column(CommonColumns.timestamp.rawValue, .integer)
            
        }
    }
    
    public func get(request: ArtisanFilter?) -> Artisan? {
        let list = getList(request: request)
        
        if let item = list.first {
            return item
        }
        
        return nil
    }
    
    public func getList(request: ArtisanFilter?) -> [Artisan] {
        do {
            let list = try _dbQueue.read({ db in
                try Artisan.fetchAll(db, request: request, tableName: _tableName)
            })
            
            return list
        } catch let error{
            assertionFailure(error.localizedDescription)
        }
        
        return []
    }
    
    public func put(model: Artisan) {
        putList(models: [model])
    }
    
    public func putList(models: [Artisan]) {
        do {
            try _dbQueue.inTransaction { db in
                
                for item in models {
                    
                    try item.insert(db, tableName: _tableName)
                }
                
                return .commit
            }
        } catch {
            assertionFailure()
        }
    }
    
    public func update(model: Artisan) -> Bool {
        return false
    }
    
    public func isCached(request: ArtisanFilter?) -> Bool {
        do {
            let total = try _dbQueue.read { db in
                try Artisan.fetchCount(db, request: request, tableName: _tableName)
            }
            
            return total > 0
        } catch {
            return false
        }
    }
    
    public func isExpired(request: ArtisanFilter?) -> Bool {
        do {
            let total = try _dbQueue.read { db in
                try Artisan.isExpired(db, request: request, tableName: _tableName, expiredAfter: _expiredAfter)
            }
            
            return total < 1
        } catch {
            return true
        }
    }
    
    public func remove(model: Artisan) {
        // Do Nothing
    }
    
    public func remove(request: ArtisanFilter) {
        do {
            let _ = try _dbQueue.write { db in
                try Artisan.delete(db, request: request, tableName: _tableName)
            }
        } catch {
            assertionFailure()
        }
    }
    
    public func removeAll() {
        do {
            let _ = try _dbQueue.write { db in
                try Artisan.deleteAll(db, tableName: _tableName)
            }
        } catch {
            assertionFailure()
        }
    }
    
    public static func dropTable(db: Database, tableName: String) throws{
        try db.execute(sql: """
            DROP TABLE IF EXISTS \(tableName);
            DROP TABLE IF EXISTS \(tableName)\(TableNames.Artisan.Relation.service);
            DROP TABLE IF EXISTS \(tableName)\(TableNames.Artisan.Relation.category);
            DROP TABLE IF EXISTS \(tableName)\(TableNames.Artisan.Relation.categoryType);
        """)
    }
}
