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
            body.column(Booking.Columns.invoice.rawValue, .text).notNull()
            body.column(Booking.Columns.status.rawValue, .integer).notNull()
            body.column(Booking.Columns.eventName.rawValue, .text).notNull()
            body.column(Booking.Columns.start.rawValue, .integer).notNull()
            body.column(Booking.Columns.totalPrice.rawValue, .text).notNull()
            body.column(Booking.Columns.createdAt.rawValue, .integer).notNull()
            body.column(Booking.Columns.updatedAt.rawValue, .integer).notNull()
            body.column(Booking.Columns.hasBid.rawValue, .boolean).notNull()
            body.column(Booking.Columns.isCustom.rawValue, .boolean).notNull()
            body.column(Booking.Columns.paymentStatus.rawValue, .integer).notNull()
            body.column(Booking.Columns.notes.rawValue, .text)
            body.column(Paging.Columns.currentPage.rawValue, .integer)
            body.column(Paging.Columns.limitPerPage.rawValue, .integer)
            body.column(Paging.Columns.totalPage.rawValue, .integer)
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.artisan)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
            body.column(Artisan.Columns.id.rawValue, .integer)
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
            body.column(Artisan.Columns.distance.rawValue, .integer)
            body.column(Artisan.Columns.hasReview.rawValue, .boolean)
            body.column(Paging.Columns.currentPage.rawValue, .integer)
            body.column(Paging.Columns.limitPerPage.rawValue, .integer)
            body.column(Paging.Columns.totalPage.rawValue, .integer)
            body.column(CommonColumns.timestamp.rawValue, .integer)
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.customer)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
            body.column(User.Columns.id.rawValue, .integer).notNull()
            body.column(User.Columns.email.rawValue, .text).notNull()
            body.column(User.Columns.name.rawValue, .text).notNull()
            body.column(User.Columns.phone.rawValue, .text).notNull()
            body.column(User.Columns.status.rawValue, .text).notNull()
            body.column(User.Columns.createdAt.rawValue, .integer).notNull()
            body.column(User.Columns.updatedAt.rawValue, .integer).notNull()
            body.column(User.Columns.dob.rawValue, .integer)
            body.column(User.Columns.gender.rawValue, .text)
            body.column(User.Columns.avatar.rawValue, .text)
            body.column(User.Columns.avatarServingURL.rawValue, .text)
            body.column(User.Columns.emailConfirmed.rawValue, .text)
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.address)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
            body.column(Address.Columns.id.rawValue, .integer)
            body.column(Address.Columns.userId.rawValue, .integer).notNull()
            body.column(Address.Columns.provinceId.rawValue, .integer).notNull()
            body.column(Address.Columns.districtId.rawValue, .integer).notNull()
            body.column(Address.Columns.areaId.rawValue, .integer).notNull()
            body.column(Address.Columns.name.rawValue, .text).notNull()
            body.column(Address.Columns.detail.rawValue, .text).notNull()
            body.column(Address.Columns.provinceName.rawValue, .text).notNull()
            body.column(Address.Columns.districtName.rawValue, .text).notNull()
            body.column(Address.Columns.districtType.rawValue, .text).notNull()
            body.column(Address.Columns.subDistrictName.rawValue, .text).notNull()
            body.column(Address.Columns.urbanVillageName.rawValue, .text).notNull()
            body.column(Address.Columns.postalCode.rawValue, .text).notNull()
            body.column(Address.Columns.lat.rawValue, .double)
            body.column(Address.Columns.lon.rawValue, .double)
            
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.bookingService)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
            body.column(Booking.BookingService.Columns.serviceId.rawValue, .integer).notNull()
            body.column(Booking.BookingService.Columns.title.rawValue, .text).notNull()
            body.column(Booking.BookingService.Columns.price.rawValue, .text).notNull()
            body.column(Booking.BookingService.Columns.quantity.rawValue, .integer).notNull()
            body.column(Booking.BookingService.Columns.notes.rawValue, .text)
            body.column(Booking.BookingService.Columns.updatedAt.rawValue, .integer)
        }
        
        try db.create(table: "\(tableName)\(TableNames.Booking.Relation.customizeRequestService)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(tableName, column: Booking.Columns.id.rawValue, onDelete: .cascade)
            body.column(Booking.CustomizeRequestService.Columns.serviceId.rawValue, .integer).notNull()
            body.column(Booking.CustomizeRequestService.Columns.title.rawValue, .text).notNull()
            body.column(Booking.CustomizeRequestService.Columns.price.rawValue, .text).notNull()
            body.column(Booking.CustomizeRequestService.Columns.quantity.rawValue, .integer).notNull()
            body.column(Booking.CustomizeRequestService.Columns.updatedAt.rawValue, .integer)
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
                    service.timestamp = timestamp
                    
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
                model.timestamp = Date().timeIntervalSince1970
                
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



