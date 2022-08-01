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
            body.column(Booking.Columns.id.rawValue, .text).unique(onConflict: .replace)
            body.column(Booking.Columns.bookingNumber.rawValue, .text)
            body.column(Booking.Columns.eventName.rawValue, .text)
            body.column(Booking.BookingStatus.Columns.id.rawValue, .integer)
            body.column(Booking.BookingStatus.Columns.title.rawValue, .text)
            body.column(Booking.BookingStatus.Columns.description.rawValue, .text)
            body.column(Booking.BookingStatus.Columns.status.rawValue, .text)
            body.column(Booking.Columns.eventDate.rawValue, .text)
            body.column(Booking.Columns.platformFee.rawValue, .numeric)
            body.column(Booking.Columns.discount.rawValue, .double)
            body.column(Booking.Columns.paymentURL.rawValue, .text)
            body.column(Booking.Columns.totalDiscount.rawValue, .double)
            body.column(Booking.Columns.grandTotal.rawValue, .numeric)
            body.column(Paging.Columns.currentPage.rawValue, .integer)
            body.column(Paging.Columns.limitPerPage.rawValue, .integer)
            body.column(Paging.Columns.totalPage.rawValue, .integer)
            body.column(CommonColumns.timestamp.rawValue, .integer)
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.artisan)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .text).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
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
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.customer)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .text).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
            body.column(NewProfile.Columns.id.rawValue, .text).notNull().unique(onConflict: .replace)
            body.column(NewProfile.Columns.email.rawValue, .text)
            body.column(NewProfile.Columns.name.rawValue, .text)
            body.column(NewProfile.Columns.phoneNumber.rawValue, .text)
            body.column(NewProfile.Columns.facebookID.rawValue, .text)
            body.column(NewProfile.Columns.googleID.rawValue, .text)
            body.column(NewProfile.Columns.appleID.rawValue, .text)
            body.column(NewProfile.Columns.metadata.rawValue, .blob)
            body.column(NewProfile.Columns.avatar.rawValue, .blob)
            body.column(NewProfile.Columns.status.rawValue, .text)
            body.column(NewProfile.Columns.created_at.rawValue, .date)
        }

        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.venue)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .text).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
            body.column(Address.Columns.id.rawValue, .text)
            body.column(Address.Columns.name.rawValue, .text)
            body.column(Address.Columns.latitude.rawValue, .double)
            body.column(Address.Columns.longitude.rawValue, .double)
            body.column(Address.Columns.notes.rawValue, .text)
            body.column(Address.Columns.address.rawValue, .text)
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.bookingService)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .text).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade).notNull()
            body.column(Booking.Service.Columns.id.rawValue, .text)
            body.column(Booking.Service.Columns.title.rawValue, .text)
            body.column(Booking.Service.Columns.notes.rawValue, .text)
            body.column(Booking.Service.Columns.quantity.rawValue, .integer)
            body.column(Booking.Service.Columns.price.rawValue, .numeric)
            body.column(Booking.Service.Columns.discount.rawValue, .double)
            body.column(Booking.Service.Columns.categoryId.rawValue, .integer)
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.statusHistory)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .text).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade).notNull()
            body.column(Booking.StatusHistory.Columns.id.rawValue, .integer)
            body.column(Booking.BookingStatus.Columns.id.rawValue, .integer)
            body.column(Booking.BookingStatus.Columns.title.rawValue, .text)
            body.column(Booking.BookingStatus.Columns.description.rawValue, .text)
            body.column(Booking.BookingStatus.Columns.status.rawValue, .text)
            body.column(Booking.StatusHistory.Columns.notes.rawValue, .text)
            body.column(Booking.StatusHistory.Columns.createdAt.rawValue, .date)
            body.column(Booking.StatusHistory.Columns.updatedAt.rawValue, .date)
        }
    }
    
    public static func dropOldTable(db: Database, tableName: String) throws{
        try db.execute(sql: """
            DROP TABLE IF EXISTS \(tableName);
            DROP TABLE IF EXISTS \(tableName)\(TableNames.Booking.Relation.artisan);
            DROP TABLE IF EXISTS \(tableName)\(TableNames.Booking.Relation.customer);
            DROP TABLE IF EXISTS \(tableName)\(TableNames.Booking.Relation.venue);
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
                    service.timeStamp = timestamp
                    
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
                model.timeStamp = Date().timeIntervalSince1970
                
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



