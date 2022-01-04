//
//  ArtisanServiceSQLCache.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 25/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class ArtisanServiceSQLCache<R>: SQLCache<R, ArtisanService> {
    
    public static func createTable(db: Database) throws {
       
        try db.create(table: ArtisanService.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(ArtisanService.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(ArtisanService.Columns.artisanId.rawValue, .integer).notNull()
            body.column(ArtisanService.Columns.title.rawValue, .text).notNull()
            body.column(ArtisanService.Columns.description.rawValue, .text).notNull()
            body.column(ArtisanService.Columns.price.rawValue, .text).notNull()
            body.column(ArtisanService.Columns.status.rawValue, .text).notNull()
            body.column(ArtisanService.Columns.cover.rawValue, .text).notNull()
            body.column(ArtisanService.Columns.coverServingURL.rawValue, .text)
            body.column(Paging.Columns.currentPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.limitPerPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.totalPage.rawValue, .integer).notNull()
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
        
        try db.create(table: ArtisanService.ServiceType.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(ArtisanService.databaseTableName, column: ArtisanService.Columns.id.rawValue, onDelete: .cascade)
            body.column(ArtisanService.ServiceType.Columns.id.rawValue, .integer).notNull()
            body.column(ArtisanService.ServiceType.Columns.serviceCategoryId.rawValue, .integer).notNull()
            body.column(ArtisanService.ServiceType.Columns.name.rawValue, .text).notNull()
        }
        
        try db.create(table: ArtisanService.ServiceTag.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(ArtisanService.databaseTableName, column: ArtisanService.Columns.id.rawValue, onDelete: .cascade)
            body.column(ArtisanService.ServiceTag.Columns.tag.rawValue, .text).notNull()
        }
    }
    
    public override func getList(request: R? = nil) -> [ArtisanService] {
        guard let request = request as? ListRequest else { return [] }
        
        do {
            let list = try dbQueue.read { db -> [ArtisanService] in
                return try ArtisanService.fetchAll(db, request: request)
            }
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public override func put(model: ArtisanService) {
        putList(models: [model])
    }
    
    public override func putList(models: [ArtisanService]) {
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
    
    public override func update(model: ArtisanService) -> Bool {
        do {
            let _ = try dbQueue.write { db in
                try model.update(db)
            }
        } catch {
            assertionFailure()
        }
        
        return true
    }
    
    public override func remove(model: ArtisanService) {
        do {
            let _ = try dbQueue.write { db in
                try ArtisanService.deleteOne(db, key: [ArtisanService.Columns.id.rawValue: model.id])
            }
        } catch {
            assertionFailure()
        }
    }
    
    public override func getFilterQueries(request: R?) -> String? {
        guard let request = request as? ListRequestType else { return nil }
        
        var filter = "\(ArtisanService.databaseTableName).\(CommonColumns._id) != 0"
        
        if request.page > 0 && !request.ignorePaging {
            filter += " AND \(Paging.Columns.currentPage.rawValue) = \(request.page)"
        }
        
        if let id = request.id, id > 0 {
            filter += " AND \(ArtisanService.Columns.artisanId.rawValue) = \(id)"
        }
        
        return filter
    }
}
