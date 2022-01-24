//
//  BookingSQLCache.swift
//  Booking
//
//  Created by Fandy Gotama on 30/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

open class BookingSQLCache: Cache {

    public typealias R = BookingListRequest
    public typealias T = Booking
    
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
            body.column(Booking.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(Booking.Columns.bookingNumber.rawValue, .text)
            body.column(Booking.Columns.eventName.rawValue, .text)
            body.column(Booking.Columns.clientName.rawValue, .text)
            body.column(Booking.Columns.status.rawValue, .text)
            body.column(Booking.Columns.eventDate.rawValue, .text)
            body.column(Booking.Columns.platformFee.rawValue, .text)
            body.column(Booking.Columns.discount.rawValue, .double)
            body.column(Booking.Columns.paymentURL.rawValue, .text)
            body.column(Booking.Columns.totalDiscount.rawValue, .double)
            body.column(Booking.Columns.grandTotal.rawValue, .text)
            body.column(Paging.Columns.currentPage.rawValue, .integer)
            body.column(Paging.Columns.limitPerPage.rawValue, .integer)
            body.column(Paging.Columns.totalPage.rawValue, .integer)
            body.column(CommonColumns.timestamp.rawValue, .integer)
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.bookingStatus)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
            body.column(Booking.BookingStatus.Columns.id.rawValue, .integer)
            body.column(Booking.BookingStatus.Columns.title.rawValue, .text)
            body.column(Booking.BookingStatus.Columns.description.rawValue, .text)
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.artisan)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
            body.column(Booking.Artisan.Columns.id.rawValue, .integer).notNull()
            body.column(Booking.Artisan.Columns.name.rawValue, .text).notNull()
            body.column(Booking.Artisan.Columns.avatar.rawValue, .text).notNull()
            body.column(Booking.Artisan.Columns.ratings.rawValue, .double).notNull()
            
        }
    
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.address)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
            body.column(Address.Columns.name.rawValue, .text)
            body.column(Address.Columns.detail.rawValue, .text)
            body.column(Address.Columns.address.rawValue, .text)
            body.column(Address.Columns.lat.rawValue, .double)
            body.column(Address.Columns.lon.rawValue, .double)
            
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.Invoice.invoice)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
            body.column(Booking.Invoice.Columns.id.rawValue, .text).unique(onConflict: .replace)
            body.column(Booking.Invoice.Columns.number.rawValue, .text)
            body.column(Booking.Invoice.Columns.subtotal.rawValue, .text)
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.Invoice.items)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .text).references("\(tableName)\(TableNames.Booking.Relation.Invoice.invoice)", column: Booking.Invoice.Columns.id.rawValue, onDelete: .cascade)
            body.column(Booking.Item.Columns.id.rawValue, .integer).unique()
            body.column(Booking.Item.Columns.notes.rawValue, .text)
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.Invoice.service)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references("\(tableName)\(TableNames.Booking.Relation.Invoice.items)", column: Booking.Item.Columns.id.rawValue, onDelete: .cascade).notNull()
            body.column(Booking.Service.Columns.name.rawValue, .text)
            body.column(Booking.Service.Columns.qty.rawValue, .integer)
            body.column(Booking.Service.Columns.price.rawValue, .text)
            body.column(Booking.Service.Columns.discount.rawValue, .double)
            body.column(Booking.Service.Columns.total.rawValue, .text)
        }
    }
    
    public static func dropOldTable(db: Database, tableName: String) throws{
        try db.execute(sql: """
            DROP TABLE IF EXISTS \(tableName);
            DROP TABLE IF EXISTS \(tableName)\(TableNames.Booking.Relation.artisan);
            DROP TABLE IF EXISTS \(tableName)\(TableNames.Booking.Relation.customer);
            DROP TABLE IF EXISTS \(tableName)\(TableNames.Booking.Relation.address);
            DROP TABLE IF EXISTS \(tableName)\(TableNames.Booking.Relation.bookingService);
            DROP TABLE IF EXISTS \(tableName)\(TableNames.Booking.Relation.customizeRequestService);
        """)
    }
    
    public func get(request: BookingListRequest?) -> Booking? {
        let bookings = getList(request: request)
        
        if !bookings.isEmpty {
            return bookings[0]
        } else {
            return nil
        }
    }
    
    public func getList(request: BookingListRequest? = nil) -> [Booking] {
        do {
            let list = try _dbQueue.read({ db -> [Booking] in
                try Booking.fetchAll(db, request: request, tableName: _tableName)
            })
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public func put(model: Booking) {
        putList(models: [model])
    }
    
    public func putList(models: [Booking]) {
        let timestamp = Date().timeIntervalSince1970
        
        do {
            try _dbQueue.inTransaction { db in
                
                for service in models {
//                    service.timestamp = timestamp
                    
                    try service.insert(db, tableName: _tableName)
                }
                
                return .commit
            }
        } catch {
            assertionFailure()
        }
    }
    
    @discardableResult
    public func update(model: Booking) -> Bool {
        do {
            try _dbQueue.inTransaction { db in
//                model.timestamp = Date().timeIntervalSince1970
                
                try model.update(db, tableName: _tableName)
                
                return .commit
            }
        } catch {
            assertionFailure()
        }
        
        return true
    }
    
    public func remove(model: Booking) {
        do {
            let _ = try _dbQueue.write { db in
                try Booking.delete(db, model: model, tableName: _tableName)
            }
        } catch {
            assertionFailure()
        }
    }
    
    public func remove(request: BookingListRequest) {
        do {
            let _ = try _dbQueue.write { db in
                try Booking.delete(db, request: request, tableName: _tableName)
            }
        } catch {
            assertionFailure()
        }
    }
    
    public func removeAll() {
        do {
            let _ = try _dbQueue.write { db in
                try Booking.deleteAll(db, tableName: _tableName)
            }
        } catch {
            assertionFailure()
        }
    }
    
    public func isCached(request: BookingListRequest?) -> Bool {
        do {
            let total = try _dbQueue.read { db in
                try Booking.fetchCount(db, request: request, tableName: _tableName)
            }
            
            return total > 0
        } catch {
            return false
        }
    }
    
    public func isExpired(request: BookingListRequest?) -> Bool {
        do {
            let total = try _dbQueue.read { db in
                try Booking.isExpired(db, request: request, tableName: _tableName, expiredAfter: _expiredAfter)
            }
            
            return total < 1
        } catch {
            return true
        }
    }
    
    public func getFilterQueries(request: BookingListRequest?) -> String? {
        return Booking.getQueryStatement(request: request, tableName: _tableName).replacingOccurrences(of: "WHERE", with: "")
    }
}



