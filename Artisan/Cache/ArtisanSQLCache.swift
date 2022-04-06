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
            body.column(Artisan.Columns.id.rawValue, .integer).notNull().unique(onConflict: .replace)
            body.column(Artisan.Columns.name.rawValue, .text)
            body.column(Artisan.Columns.username.rawValue, .text)
            body.column(Artisan.Columns.email.rawValue, .text)
            body.column(Artisan.Columns.phone.rawValue, .text)
            body.column(Artisan.Columns.dob.rawValue, .integer)
            body.column(Artisan.Columns.about.rawValue, .text)
            body.column(Artisan.Columns.status.rawValue, .text)
            body.column(Artisan.Columns.createdAt.rawValue, .integer)
            body.column(Artisan.Columns.updatedAt.rawValue, .integer)
            body.column(Artisan.Columns.gender.rawValue, .text)
            body.column(Artisan.Columns.avatar.rawValue, .text)
            body.column(Artisan.Columns.avatarServingURL.rawValue, .text)
            body.column(Artisan.Columns.reviewRating.rawValue, .integer)
            body.column(Artisan.Favorite.Columns.count.rawValue, .integer)
            body.column(Artisan.Favorite.Columns.isFavorite.rawValue, .boolean)
            body.column(Artisan.Booking.Columns.count.rawValue, .integer)
            body.column(Artisan.Columns.emailConfirmed.rawValue, .boolean)
            body.column(Artisan.Columns.instagram.rawValue, .text)
            body.column(Artisan.Columns.level.rawValue, .text)
            body.column(Artisan.Columns.hasReview.rawValue, .boolean)
            body.column(Artisan.Columns.distance.rawValue, .integer)
            body.column(Paging.Columns.currentPage.rawValue, .integer)
            body.column(Paging.Columns.limitPerPage.rawValue, .integer)
            body.column(Paging.Columns.totalPage.rawValue, .integer)
            body.column(CommonColumns.timestamp.rawValue, .integer)
        }
        
        try db.create(table: "\(tableName)\(TableNames.Artisan.Relation.service)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Artisan.Columns.id.rawValue, onDelete: .cascade)
            body.column(Artisan.Service.Columns.id.rawValue, .integer).notNull()
            body.column(Artisan.Service.Columns.title.rawValue, .text).notNull()
            body.column(Artisan.Service.Columns.cover.rawValue, .text).notNull()
            body.column(Artisan.Service.Columns.coverServingURL.rawValue, .text)
        }

        try db.create(table: "\(tableName)\(TableNames.Artisan.Relation.category)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Artisan.Columns.id.rawValue, onDelete: .cascade)
            body.column(Artisan.Category.Columns.id.rawValue, .integer).notNull()
            body.column(Artisan.Category.Columns.title.rawValue, .text).notNull()
        }
        
        try db.create(table: "\(tableName)\(TableNames.Artisan.Relation.categoryType)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Artisan.Columns.id.rawValue, onDelete: .cascade)
            body.column(Artisan.CategoryType.Columns.id.rawValue, .integer).notNull()
            body.column(Artisan.CategoryType.Columns.serviceCategoryId.rawValue, .integer).notNull()
            body.column(Artisan.CategoryType.Columns.title.rawValue, .text).notNull()
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
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public func put(model: Artisan) {
        putList(models: [model])
    }
    
    public func putList(models: [Artisan]) {
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
