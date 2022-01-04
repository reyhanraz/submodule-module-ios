//
//  CategoryTypesSQLCache.swift
//  Category
//
//  Created by Fandy Gotama on 22/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class CategoryTypeSQLCache: SQLCache<ListRequest, CategoryType> {
    
    public static func createTable(db: Database) throws {
        try db.create(table: CategoryType.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CategoryType.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(CategoryType.Columns.serviceCategoryId.rawValue, .integer).references(Category.databaseTableName, column: Category.Columns.id.rawValue, onDelete: .cascade)
            body.column(CategoryType.Columns.description.rawValue, .text).notNull()
            body.column(CategoryType.Columns.name.rawValue, .text).notNull().collate(.localizedCaseInsensitiveCompare)
            body.column(CategoryType.Columns.status.rawValue, .integer).notNull()
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
    }
    
    public override func getList(request: ListRequest? = nil) -> [CategoryType] {
        do {
            let list = try dbQueue.read({ db -> [CategoryType] in
                if let request = getFilterQueries(request: request) {
                    return try CategoryType.filter(sql: request).fetchAll(db)
                } else {
                    return try CategoryType.fetchAll(db)
                }
            })
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public override func putList(models: [CategoryType]) {
        let timestamp = Date().timeIntervalSince1970
        
        do {
            try dbQueue.inTransaction { db in
                
                for category in models {
                    try CategoryType(id: category.id,
                                     serviceCategoryId: category.serviceCategoryId,
                                     name: category.name,
                                     description: category.description,
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
        guard let id = request?.id else { return nil }
        
        var filter: String?
        
        if id > 0 {
            filter = "\(CategoryType.Columns.serviceCategoryId) = \(id)"
        }
        
        return filter
    }
}
