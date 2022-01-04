//
//  CustomizeRequestSQLCache.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 06/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class CustomizeRequestSQLCache: SQLCache<CustomizeListRequest, CustomizeRequest> {
    
    public static func createTable(db: Database) throws {
        
        try db.create(table: CustomizeRequest.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CustomizeRequest.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(CustomizeRequest.Columns.status.rawValue, .integer).notNull()
            body.column(CustomizeRequest.Columns.eventName.rawValue, .text).notNull()
            body.column(CustomizeRequest.Columns.start.rawValue, .integer).notNull()
            body.column(CustomizeRequest.Columns.totalPrice.rawValue, .text).notNull()
            body.column(CustomizeRequest.Columns.createdAt.rawValue, .integer).notNull()
            body.column(CustomizeRequest.Columns.updatedAt.rawValue, .integer).notNull()
            body.column(CustomizeRequest.Columns.notes.rawValue, .text)
            body.column(Paging.Columns.currentPage.rawValue, .integer)
            body.column(Paging.Columns.limitPerPage.rawValue, .integer)
            body.column(Paging.Columns.totalPage.rawValue, .integer)
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
        
        try db.create(table: "\(CustomizeRequest.databaseTableName)\(TableNames.CustomizeRequest.artisan)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(CustomizeRequest.databaseTableName, column: CustomizeRequest.Columns.id.rawValue, onDelete: .cascade)
            body.column(Artisan.Columns.id.rawValue, .integer).notNull()
            body.column(Artisan.Columns.name.rawValue, .text).notNull()
            body.column(Artisan.Columns.email.rawValue, .text).notNull()
            body.column(Artisan.Columns.phone.rawValue, .text).notNull()
            body.column(Artisan.Columns.dob.rawValue, .integer)
            body.column(Artisan.Columns.about.rawValue, .text)
            body.column(Artisan.Columns.status.rawValue, .text).notNull()
            body.column(Artisan.Columns.createdAt.rawValue, .integer).notNull()
            body.column(Artisan.Columns.updatedAt.rawValue, .integer).notNull()
            body.column(Artisan.Columns.gender.rawValue, .text)
            body.column(Artisan.Columns.avatar.rawValue, .text)
            body.column(Artisan.Columns.reviewRating.rawValue, .integer)
            body.column(Artisan.Favorite.Columns.count.rawValue, .integer)
            body.column(Artisan.Favorite.Columns.isFavorite.rawValue, .boolean)
            body.column(Artisan.Booking.Columns.count.rawValue, .integer)
            body.column(Artisan.Columns.emailConfirmed.rawValue, .boolean)
            body.column(Artisan.Columns.instagram.rawValue, .text)
            body.column(Artisan.Columns.level.rawValue, .text)
            body.column(Artisan.Columns.distance.rawValue, .integer)
            body.column(Paging.Columns.currentPage.rawValue, .integer)
            body.column(Paging.Columns.limitPerPage.rawValue, .integer)
            body.column(Paging.Columns.totalPage.rawValue, .integer)
            body.column(CommonColumns.timestamp.rawValue, .integer)
        }
        
        try db.create(table: "\(CustomizeRequest.databaseTableName)\(TableNames.CustomizeRequest.customer)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(CustomizeRequest.databaseTableName, column: CustomizeRequest.Columns.id.rawValue, onDelete: .cascade)
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
            body.column(User.Columns.emailConfirmed.rawValue, .text)
        }
        
        try db.create(table: "\(CustomizeRequest.databaseTableName)\(TableNames.CustomizeRequest.address)") { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(CustomizeRequest.databaseTableName, column: CustomizeRequest.Columns.id.rawValue, onDelete: .cascade)
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
        }
        
        try db.create(table: CustomizeRequest.CustomizeRequestService.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(CustomizeRequest.databaseTableName, column: CustomizeRequest.Columns.id.rawValue, onDelete: .cascade)
            body.column(CustomizeRequest.CustomizeRequestService.Columns.serviceId.rawValue, .integer).notNull()
            body.column(CustomizeRequest.CustomizeRequestService.Columns.title.rawValue, .text).notNull()
            body.column(CustomizeRequest.CustomizeRequestService.Columns.price.rawValue, .text).notNull()
            body.column(CustomizeRequest.CustomizeRequestService.Columns.quantity.rawValue, .integer).notNull()
            body.column(CustomizeRequest.CustomizeRequestService.Columns.updatedAt.rawValue, .integer)
        }
    }
    
    public override func get(request: CustomizeListRequest?) -> CustomizeRequest? {
        let bookings = getList(request: request)
        
        if !bookings.isEmpty {
            return bookings[0]
        } else {
            return nil
        }
    }
    
    public override func getList(request: CustomizeListRequest? = nil) -> [CustomizeRequest] {
        do {
            let list = try dbQueue.read({ db -> [CustomizeRequest] in
                try CustomizeRequest.fetchAll(db, request: request)
            })
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    override public func put(model: CustomizeRequest) {
        putList(models: [model])
    }
    
    override public func putList(models: [CustomizeRequest]) {
        let timestamp = Date().timeIntervalSince1970
        
        do {
            try dbQueue.inTransaction { db in
                
                for service in models {
                    service.timestamp = timestamp
                    
                    try service.insert(db)
                }
                
                return .commit
            }
        } catch {
            print("TESET: \(error)")
            
            assertionFailure()
        }
    }
    
    override public func update(model: CustomizeRequest) -> Bool {
        do {
            try dbQueue.inTransaction { db in
                try model.update(db)
                
                return .commit
            }
        } catch {
            assertionFailure()
        }
        
        return true
    }
    
    override public func remove(model: CustomizeRequest) {
        do {
            let _ = try dbQueue.write { db in
                try CustomizeRequest.deleteOne(db, key: [CustomizeRequest.Columns.id.rawValue: model.id])
            }
        } catch {
            assertionFailure()
        }
    }
    
    override public func getFilterQueries(request: CustomizeListRequest?) -> String? {
        return CustomizeRequest.getQueryStatement(request: request, tableName: CustomizeRequest.databaseTableName).replacingOccurrences(of: "WHERE", with: "")
    }
}




