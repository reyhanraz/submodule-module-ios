//
//  CategorySQLCache.swift
//  Category
//
//  Created by Fandy Gotama on 18/05/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class CategorySQLCache: SQLCache<CategoryListRequest, Category> {
    
    public static func createTable(db: Database) throws {
        try db.create(table: Category.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey().unique(onConflict: .replace)
            body.column(Category.Columns.name.rawValue, .text).notNull().collate(.localizedCaseInsensitiveCompare)
            body.column(Category.Columns.status.rawValue, .text)
            body.column(Category.Columns.icon_url.rawValue, .text)
            body.column(Category.Columns.childrens.rawValue, .blob)
            body.column(Category.Columns.parentId.rawValue, .integer)
            body.column(CommonColumns.timestamp.rawValue, .numeric)

        }
    }
    
    public override func getList(request: CategoryListRequest? = nil) -> [Category] {
        
        
        do {
            let list = try dbQueue.read({ db -> [Category] in
                try fetchCategoryChildren(db, parentId: nil)
            })
            
            return list
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
        
        return []
    }
    
    func fetchCategoryChildren(_ db: Database, parentId: Int?) throws -> [Category] {
        let list = try dbQueue.unsafeReentrantRead({ db -> [Category] in
            let rows: [Row]
            
            if let parentId = parentId {
                rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Category.databaseTableName) WHERE \(Category.Columns.parentId.rawValue) = \(parentId)")
            } else {
                rows = try Row.fetchAll(db, sql: "SELECT * FROM \(Category.databaseTableName) WHERE \(Category.Columns.parentId.rawValue) IS NULL")
            }
            
            return try rows.map { row in
                let category = try fetchCategoryChildren(db, parentId: row[CommonColumns._id])
                return Category(id: row[CommonColumns._id],
                                name: row[Category.Columns.name],
                                icon_url: row[Category.Columns.icon_url],
                                status: ItemStatus(string: row[Category.Columns.status]),
                                childrens: category)
            }
        })
        
        return list
    }
    
    func insertCategory(_ db: Database, category: Category, parentId: Int?) throws {
        try db.execute(sql:
        """
        INSERT INTO \(Category.databaseTableName)
        (\(CommonColumns._id.rawValue),
        \(Category.Columns.name.rawValue),
        \(Category.Columns.icon_url.rawValue),
        \(Category.Columns.status.rawValue),
        \(Category.Columns.parentId.rawValue),
        \(CommonColumns.timestamp))
        VALUES (?, ?, ?, ?, ?, ?)
        """, arguments: [category.id,
                         category.name,
                         category.icon_url,
                         category.status.stringValue,
                         parentId,
                         Date().timeIntervalSince1970])
    }
    
    public override func put(model: Category) {
        do {
            try dbQueue.inTransaction { db in
                try insertCategory(db, category: model, parentId: nil)
                return .commit
            }
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }

    public override func putList(models: [Category]) {
        do {
            try dbQueue.inTransaction { db in
                try models.forEach({ category in
                    try insertCategory(db, category: category, parentId: category.parentId)
                    
                    try category.childrens?.forEach({ _category in
                        try insertCategory(db, category: _category, parentId: category.id)
                        
                        try _category.childrens?.forEach({ category in
                            try insertCategory(db, category: category, parentId: _category.id)
                        })
                        
                    })
                    
                })
                
                return .commit
    
            }
            
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
        
        
    }
    
    public override func getFilterQueries(request: CategoryListRequest?) -> String? {
        return nil
    }
}


