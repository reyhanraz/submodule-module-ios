//
//  Cart+SQL.swift
//  Booking
//
//  Created by Fandy Gotama on 29/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

extension Cart: MultiTableRecord {
    public typealias R = Int
    
    public func encode(to container: inout PersistenceContainer) {
        container[Columns.artisanId] = artisanId
        container[Columns.name] = name
        container[Columns.avatar] = avatar?.url
        container[Columns.avatarServingURL] = avatar?.servingURL
        container[CommonColumns.timestamp] = timestamp
    }
    
    public var contentValues: [String : DatabaseValueConvertible?] {
        return [:]
    }
    
    public func insert(_ db: Database) throws {
        try performInsert(db)
        
        try updateRelations(db)
    }
    
    public func update(_ db: Database) throws {
        try db.execute(sql: "DELETE FROM \(Cart.Item.databaseTableName) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [artisanId])
        
        try updateRelations(db)
    }
    
    public static func fetchAll(_ db: Database, request: Int?) throws -> [Cart] {
        let query = getQueryStatement(request: request, tableName: Cart.databaseTableName)
        
        let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Cart.databaseTableName) \(query)")
        
        return try rows.map { row in
            let id = row[Cart.Columns.artisanId]
            
            let itemRows = try Row.fetchAll(db, sql: "SELECT * FROM \(Cart.Item.databaseTableName) WHERE \(CommonColumns.fkId.rawValue) = ? ORDER BY _id ASC", arguments: [id])
            
            let items = try itemRows.map { itemRow -> Item in
                let id = itemRow[CommonColumns._id]
                
                let typeRows = try Row.fetchAll(db, sql: "SELECT * FROM \(Cart.Item.ServiceType.databaseTableName) WHERE \(CommonColumns.fkId.rawValue) = ? ORDER BY _id ASC", arguments: [id])
                
                let types = typeRows.map { Cart.Item.ServiceType(id: $0[Cart.Item.ServiceType.Columns.id], name: $0[Cart.Item.ServiceType.Columns.name]) }
                
                return Item(id: itemRow[Cart.Item.Columns.id],
                            title: itemRow[Cart.Item.Columns.title],
                            description: itemRow[Cart.Item.Columns.description],
                            artisanId: row[Cart.Columns.artisanId],
                            serviceTypes: types,
                            serviceFee: Decimal(string: itemRow[Cart.Item.Columns.serviceFee]) ?? 0,
                            quantity: itemRow[Cart.Item.Columns.quantity],
                            notes: itemRow[Cart.Item.Columns.notes])
            }
            
            let avatar: Media?
            let avatarServingURL: URL?

            if let image = row[Cart.Columns.avatarServingURL] as? String, let url = URL(string: image) {
                avatarServingURL = url
            } else {
                avatarServingURL = nil
            }

            if let image = row[Cart.Columns.avatar] as? String, let url = URL(string: image) {
                avatar = Media(url: url, servingURL: avatarServingURL)
            } else {
                avatar = nil
            }
            
            return Cart(
                artisanId: row[Cart.Columns.artisanId],
                name: row[Cart.Columns.name],
                avatar: avatar,
                avatarServingURL: avatar?.servingURL,
                items: items)
        }
    }
    
    public static func getQueryStatement(request: Int?, tableName: String) -> String {
        var query = "WHERE \(tableName).\(CommonColumns._id.rawValue) != -1"
        
        if let id = request, id > 0 {
            query += " AND \(tableName).\(Cart.Columns.artisanId.rawValue) = \(id)"
        }
        
        return query
    }
    
    private func updateRelations(_ db: Database) throws {
        try items.forEach { item in
            
            try db.execute(sql: """
                INSERT INTO \(Cart.Item.databaseTableName)
                (\(CommonColumns.fkId.rawValue), \(Cart.Item.Columns.id.rawValue), \(Cart.Item.Columns.title.rawValue), \(Cart.Item.Columns.description.rawValue), \(Cart.Item.Columns.serviceFee.rawValue), \(Cart.Item.Columns.quantity.rawValue), \(Cart.Item.Columns.notes.rawValue))
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """, arguments: [artisanId, item.id, item.title, item.description, "\(item.serviceFee)", item.quantity, item.notes])
            
            try item.serviceTypes.forEach { type in
                try db.execute(sql: """
                    INSERT INTO \(Cart.Item.ServiceType.databaseTableName)
                    (\(CommonColumns.fkId.rawValue), \(Cart.Item.ServiceType.Columns.id.rawValue), \(Cart.Item.ServiceType.Columns.name.rawValue))
                    VALUES (?, ?, ?)
                    """, arguments: [db.lastInsertedRowID, type.id, type.name])
                
            }
        }
    }
}

extension Cart: TableRecord {
    static let items = hasMany(Cart.Item.self)
}

extension Cart.Item: TableRecord {
    static let cart = belongsTo(Cart.self)
    static let serviceTypes = hasMany(Cart.Item.ServiceType.self)
}

extension Cart.Item.ServiceType: TableRecord {
    static let cart = belongsTo(Cart.self)
}

