//
//  CartSQLCache.swift
//  Booking
//
//  Created by Fandy Gotama on 29/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class CartSQLCache: SQLCache<Int, Cart> {
    
    public static func createTable(db: Database) throws {
        
        try db.create(table: Cart.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(Cart.Columns.artisanId.rawValue, .integer).unique(onConflict: .replace)
            body.column(Cart.Columns.name.rawValue, .text).notNull()
            body.column(Cart.Columns.avatar.rawValue, .text)
            body.column(Cart.Columns.avatarServingURL.rawValue, .text)
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
        
        try db.create(table: Cart.Item.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(Cart.databaseTableName, column: Cart.Columns.artisanId.rawValue, onDelete: .cascade)
            body.column(Cart.Item.Columns.id.rawValue, .integer).notNull()
            body.column(Cart.Item.Columns.title.rawValue, .text).notNull()
            body.column(Cart.Item.Columns.description.rawValue, .text).notNull()
            body.column(Cart.Item.Columns.serviceFee.rawValue, .text).notNull()
            body.column(Cart.Item.Columns.quantity.rawValue, .integer).notNull()
            body.column(Cart.Item.Columns.notes.rawValue, .text)
        }
        
        try db.create(table: Cart.Item.ServiceType.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(Cart.Item.databaseTableName, column: CommonColumns._id.rawValue, onDelete: .cascade)
            body.column(Cart.Item.ServiceType.Columns.id.rawValue, .integer).notNull()
            body.column(Cart.Item.ServiceType.Columns.name.rawValue, .text).notNull()
        }
    }
    
    public override func get(request: Int?) -> Cart? {
        let carts = getList(request: request)
        
        if !carts.isEmpty {
            return carts[0]
        } else {
            return nil
        }
    }
    
    public override func getList(request: R? = nil) -> [Cart] {
        do {
            let list = try dbQueue.read({ db -> [Cart] in
                try Cart.fetchAll(db, request: request)
            })
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    override public func put(model: Cart) {
        putList(models: [model])
    }
    
    override public func putList(models: [Cart]) {
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
            assertionFailure()
        }
    }
    
    override public func update(model: Cart) -> Bool {
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
    
    override public func remove(model: Cart) {
        remove(request: model.artisanId)
    }
    
    public override func remove(request: Int) {
        do {
            let _ = try dbQueue.write { db in
                try Cart.deleteOne(db, key: [Cart.Columns.artisanId.rawValue: request])
            }
        } catch {
            assertionFailure()
        }
    }
    
    override public func getFilterQueries(request: R?) -> String? {
        return Cart.getQueryStatement(request: request, tableName: Cart.databaseTableName).replacingOccurrences(of: "WHERE", with: "")
    }
}


