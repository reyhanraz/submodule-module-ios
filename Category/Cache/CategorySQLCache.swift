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
            body.column(Category.Columns.status.rawValue, .text)
            body.column(Category.Columns.icon_url.rawValue, .text)
            body.column(Category.Columns.childrens.rawValue, .blob)
            body.column(CommonColumns.timestamp.rawValue, .numeric)

        }
    }
    
    public override func getList(request: ListRequest? = nil) -> [Category] {
        
        
        do {
            let list = try dbQueue.read({ db -> [Category] in
                let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Category.databaseTableName)")
                return try rows.map { row in
                    let decoder = JSONDecoder()
                    let category = try decoder.decode([Category].self, from: row[Category.Columns.childrens])
                    return Category(id: row[Category.Columns.id],
                                    name: row[Category.Columns.name],
                                    icon_url: row[Category.Columns.icon_url],
                                    status: ItemStatus(string: row[Category.Columns.status]),
                                    childrens: category)
                }
            })
            
            return list
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
        
        return []
    }
    
    func insertCategory(_ db: Database, category: Category) throws {
        try db.execute(sql:
        """
        INSERT INTO \(Category.databaseTableName) (\(Category.Columns.id.rawValue), \(Category.Columns.name.rawValue), \(Category.Columns.icon_url.rawValue), \(Category.Columns.status.rawValue), \(Category.Columns.childrens.rawValue), \(CommonColumns.timestamp))
        VALUES (?, ?, ?, ?, ?, ?)
        """, arguments: [category.id, category.name, category.icon_url, category.status.stringValue, category.childrenData, Date().timeIntervalSince1970])
    }
    
    public override func put(model: Category) {
        do {
            try dbQueue.inTransaction { db in
                try insertCategory(db, category: model)
                return .commit
            }
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }

    public override func putList(models: [Category]) {
        for category in models {
            put(model: category)
        }
    }
    
    public override func getFilterQueries(request: ListRequest?) -> String? {
        return nil
    }
}


