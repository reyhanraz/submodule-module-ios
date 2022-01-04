//
//  CategorySQLCache.swift
//  Category
//
//  Created by Fandy Gotama on 18/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class CategorySQLCache: SQLCache<ListRequest, Category> {
    
    public static func createTable(db: Database) throws {
        try db.create(table: Category.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(Category.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(Category.Columns.name.rawValue, .text).notNull().collate(.localizedCaseInsensitiveCompare)
            body.column(Category.Columns.status.rawValue, .integer).notNull()
            body.column(Category.Columns.order.rawValue, .integer).notNull()
            body.column(Category.Columns.icon.rawValue, .integer)
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
    }
    
    public override func getList(request: ListRequest? = nil) -> [Category] {
        do {
            let list = try dbQueue.read({ db in
                try Category.fetchAll(db)
            })
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }

    public override func putList(models: [Category]) {
        let timestamp = Date().timeIntervalSince1970
        
        do {
            try dbQueue.inTransaction { db in
                
                for category in models {
                    try Category(id: category.id,
                                 name: category.name,
                                 icon: category.icon,
                                 order: category.order,
                                 status: category.status,
                                 timestamp: timestamp).insert(db)
                }
                
                return .commit
            }
        } catch {
            assertionFailure()
        }
    }
    
    public override func getFilterQueries(request: ListRequest?) -> String? {
        return nil
    }
}


