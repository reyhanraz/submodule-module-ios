//
//  ArtisanServiceSQLCache.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 25/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform
import ServiceWrapper

public class ArtisanServiceSQLCache<R>: SQLCache<R, ArtisanService> {
        
    public static func createTable(db: Database) throws {
       
        try db.create(table: ArtisanService.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(ArtisanService.Columns.id.rawValue, .text).unique(onConflict: .replace)
            body.column(ArtisanService.Columns.title.rawValue, .text)
            body.column(ArtisanService.Columns.description.rawValue, .text)
            body.column(ArtisanService.Columns.status.rawValue, .text)
            body.column(ArtisanService.Columns.duration.rawValue, .integer)
            body.column(ArtisanService.Columns.price.rawValue, .numeric)
            body.column(ArtisanService.Columns.originalPrice.rawValue, .numeric)
            body.column(ArtisanService.Columns.category.rawValue, .blob)
            body.column(ArtisanService.Columns.images.rawValue, .blob)
            body.column(ArtisanService.Columns.artisan.rawValue, .text)
            body.column(ArtisanService.Columns.topParentId.rawValue, .numeric)
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
    }
    
    public override func getList(request: R? = nil) -> [ArtisanService] {
        guard let request = request as? ServiceListRequest else { return [] }
        
        do {
            let list = try dbQueue.read { db -> [ArtisanService] in
                return try ArtisanService.fetchAll(db, request: request)
            }
            
            return list
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
        
        return []
    }
    
    public override func put(model: ArtisanService) {
        putList(models: [model])
    }
    
    public override func putList(models: [ArtisanService]) {
        
        do {
            try dbQueue.inTransaction { db in
                
                for service in models {
                    
                    try service.insert(db)
                }
                
                return .commit
            }
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    public override func update(model: ArtisanService) -> Bool {
        do {
            let _ = try dbQueue.write { db in
                try model.update(db)
            }
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
        
        return true
    }
    
    public override func remove(model: ArtisanService) {
        do {
            let _ = try dbQueue.write { db in
                try ArtisanService.deleteOne(db, key: [ArtisanService.Columns.id.rawValue: model.id])
            }
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    public override func getFilterQueries(request: R?) -> String? {
        guard let request = request as? ServiceListRequest else { return nil }
        
        var filter = "\(ArtisanService.databaseTableName).\(CommonColumns._id) != 0"
        
        if let artisanID = request.artisan {
            filter += " AND \(ArtisanService.Columns.artisan.rawValue) == '\(artisanID)'"
        }
        
        if let category = request.category {
            filter += " AND \(ArtisanService.Columns.topParentId.rawValue) == \(category)"
        }
        
        return filter
    }
}
