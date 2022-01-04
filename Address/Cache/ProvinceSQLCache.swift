//
//  ProvinceSQLCache.swift
//  Address
//
//  Created by Fandy Gotama on 10/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class ProvinceSQLCache<R>: SQLCache<R, Province> {
    
    public static func createTable(db: Database) throws {
        try db.create(table: Province.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(Province.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(Province.Columns.mainDistrictId.rawValue, .integer).notNull()
            body.column(Province.Columns.name.rawValue, .text).notNull()
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
    }
    
    public override func getList(request: R? = nil) -> [Province] {
        do {
            let list = try dbQueue.read { db -> [Province] in
                try Province.order(Province.Columns.name.asc).fetchAll(db)
            }
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public override func put(model: Province) {
        putList(models: [model])
    }
    
    public override func putList(models: [Province]) {
        let timestamp = Date().timeIntervalSince1970
        
        do {
            try dbQueue.inTransaction { db in
                
                for record in models {
                    try Province(id: record.id,
                                 mainDistrictId: record.mainDistrictId,
                                 name: record.name,
                                 timestamp: timestamp).insert(db)
                }
                
                return .commit
            }
        } catch {
            assertionFailure()
        }
    }
    
    public override func getFilterQueries(request: R?) -> String? {
        return nil
    }
}



