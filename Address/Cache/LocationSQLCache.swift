//
//  LocationSQLCache.swift
//  Address
//
//  Created by Fandy Gotama on 29/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class LocationSQLCache<R>: SQLCache<R, Location> {
    
    public static func createTable(db: Database) throws {
        try db.create(table: Location.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(Location.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(Location.Columns.provinceId.rawValue, .integer).notNull()
            body.column(Location.Columns.provinceName.rawValue, .text).notNull()
            body.column(Location.Columns.districtId.rawValue, .integer).notNull()
            body.column(Location.Columns.districtName.rawValue, .text).notNull()
            body.column(Location.Columns.districtType.rawValue, .text).notNull()
            body.column(Location.Columns.subDistrictName.rawValue, .text).notNull()
            body.column(Location.Columns.urbanVillageName.rawValue, .text).notNull()
            body.column(Location.Columns.postalCode.rawValue, .text).notNull()
            
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
    }
    
    public override func getList(request: R? = nil) -> [Location] {
        do {
            let list = try dbQueue.read { db -> [Location] in
                try Location.order(CommonColumns._id.desc).fetchAll(db)
            }
            
            if let item = list.last, list.count > CacheConfig.maxSearchLimit {
                let _ = try dbQueue.write { db in
                    try Location.deleteOne(db, key: [Location.Columns.id.rawValue: item.id])
                }
            }
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public override func put(model: Location) {
        putList(models: [model])
    }
    
    public override func putList(models: [Location]) {
        let timestamp = Date().timeIntervalSince1970
        
        do {
            try dbQueue.inTransaction { db in
                
                for record in models {
                    try Location(id: record.id,
                                 provinceId: record.provinceId,
                                 provinceName: record.provinceName,
                                 districtId: record.districtId,
                                 districtName: record.districtName,
                                 districtType: record.districtType,
                                 subDistrictName: record.subDistrictName,
                                 urbanVillageName: record.urbanVillageName,
                                 postalCode: record.postalCode,
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


