//
//  RatingSQLCache.swift
//  Rating
//
//  Created by Fandy Gotama on 04/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class RatingSQLCache: SQLCache<ListRequest, Rating> {

    public static func createTable(db: Database) throws {
        try db.create(table: Rating.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(Rating.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(Rating.Columns.artisanId.rawValue, .integer).notNull()
            body.column(Rating.Columns.comment.rawValue, .text)
            body.column(Rating.Columns.rating.rawValue, .integer).notNull()
            body.column(Rating.Columns.updatedAt.rawValue, .integer).notNull()
            body.column(Rating.Customer.Columns.id.rawValue, .text).notNull()
            body.column(Rating.Customer.Columns.name.rawValue, .text).notNull()
            body.column(Rating.Customer.Columns.avatar.rawValue, .text)
            body.column(Rating.Customer.Columns.avatarServingURL.rawValue, .text)
            body.column(Paging.Columns.currentPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.limitPerPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.totalPage.rawValue, .integer).notNull()
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
    }
    
    public override func getList(request: ListRequest? = nil) -> [Rating] {
        do {
            let list = try dbQueue.read({ db -> [Rating] in
                if let request = getFilterQueries(request: request) {
                    return try Rating.filter(sql: request).fetchAll(db)
                } else {
                    return try Rating.fetchAll(db)
                }
                
            })
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public override func putList(models: [Rating]) {
        let timestamp = Date().timeIntervalSince1970
        
        do {
            try dbQueue.inTransaction { db in
                
                for rating in models {
                    rating.timestamp = timestamp
                    
                    try rating.insert(db)
                }
                
                return .commit
            }
        } catch {
            assertionFailure()
        }
    }
    
    public override func getFilterQueries(request: ListRequest?) -> String? {
        guard let request = request else { return nil }
        
        var filter = "\(CommonColumns._id) > 0"
        
        if let id = request.id, id > 0 {
            filter += " AND \(Rating.Columns.artisanId) = \(id)"
        }
        
        if request.page > 0 && !request.ignorePaging {
            filter += " aND \(Paging.Columns.currentPage.rawValue) = \(request.page)"
        }
        
        return filter
    }
}
