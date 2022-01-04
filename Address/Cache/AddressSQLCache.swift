//
//  AddressSQLCache.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class AddressSQLCache<R>: SQLCache<R, Address> {
    
    public override init(dbQueue: DatabaseQueue, expiredAfter: TimeInterval = CacheExpiryDate.oneMonth.rawValue) {
        super.init(dbQueue: dbQueue, expiredAfter: expiredAfter)
    }
    
    public static func createTable(db: Database) throws {
        try db.create(table: Address.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(Address.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(Address.Columns.userId.rawValue, .integer).notNull()
            body.column(Address.Columns.provinceId.rawValue, .integer)
            body.column(Address.Columns.districtId.rawValue, .integer)
            body.column(Address.Columns.areaId.rawValue, .integer)
            body.column(Address.Columns.name.rawValue, .text).notNull()
            body.column(Address.Columns.detail.rawValue, .text).notNull()
            body.column(Address.Columns.provinceName.rawValue, .text)
            body.column(Address.Columns.districtName.rawValue, .text)
            body.column(Address.Columns.districtType.rawValue, .text)
            body.column(Address.Columns.subDistrictName.rawValue, .text)
            body.column(Address.Columns.urbanVillageName.rawValue, .text)
            body.column(Address.Columns.postalCode.rawValue, .text)
            body.column(Address.Columns.lat.rawValue, .double)
            body.column(Address.Columns.lon.rawValue, .double)
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
            body.column(Address.Columns.address.rawValue, .text)
            body.column(Address.Columns.rawAddress.rawValue, .blob)
        }
    }
    
    public override func getList(request: R? = nil) -> [Address] {
        do {
            let list = try dbQueue.read({ db in
                try Address.order(CommonColumns.id.asc).fetchAll(db)
            })
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public override func update(model: Address) -> Bool {
        do {
            try dbQueue.write { db in
                let timestamp = Date().timeIntervalSince1970
                
                try db.execute(sql: """
                    UPDATE \(Address.databaseTableName) SET
                    \(Address.Columns.provinceId.rawValue) = ?,
                    \(Address.Columns.districtId.rawValue) = ?,
                    \(Address.Columns.areaId.rawValue) = ?,
                    \(Address.Columns.name.rawValue) = ?,
                    \(Address.Columns.detail.rawValue) = ?,
                    \(Address.Columns.provinceName.rawValue) = ?,
                    \(Address.Columns.districtName.rawValue) = ?,
                    \(Address.Columns.districtType.rawValue) = ?,
                    \(Address.Columns.subDistrictName.rawValue) = ?,
                    \(Address.Columns.urbanVillageName.rawValue) = ?,
                    \(Address.Columns.postalCode.rawValue) = ?,
                    \(Address.Columns.lat.rawValue) = ?,
                    \(Address.Columns.lon.rawValue) = ?,
                    \(CommonColumns.timestamp.rawValue) = ?
                    WHERE
                    \(Address.Columns.id.rawValue) = ?
                    """, arguments: [model.provinceId,
                                     model.districtId,
                                     model.areaId,
                                     model.name,
                                     model.detail,
                                     model.provinceName,
                                     model.districtName,
                                     model.districtType,
                                     model.subDistrictName,
                                     model.urbanVillageName,
                                     model.postalCode,
                                     model.lat,
                                     model.lon,
                                     timestamp, model.id])
            }
            
            return true
        } catch {
            assertionFailure()
        }
        
        return false
    }
    
    public override func put(model: Address) {
        putList(models: [model])
    }
    
    public override func putList(models: [Address]) {
        let timestamp = Date().timeIntervalSince1970
        
        do {
            try dbQueue.inTransaction { db in
                
                for record in models {
                    
                    try Address(id: record.id,
                                userId: record.userId,
                                provinceId: record.provinceId,
                                districtId: record.districtId,
                                areaId: record.areaId,
                                name: record.name,
                                detail: record.detail,
                                provinceName: record.provinceName,
                                districtName: record.districtName,
                                districtType: record.districtType,
                                subDistrictName: record.subDistrictName,
                                urbanVillageName: record.urbanVillageName,
                                postalCode: record.postalCode,
                                lat: record.lat,
                                lon: record.lon,
                                timestamp: timestamp,
                                address: record.address,
                                rawAddress: record.rawAddress).insert(db)
                }
                
                return .commit
            }
        } catch {
            assertionFailure()
        }
    }
    
    public override func remove(model: Address) {
        do {
            let _ = try dbQueue.write { db in
                try Address.deleteOne(db, key: [Address.Columns.id.rawValue: model.id])
            }
        } catch {
            assertionFailure()
        }
    }
    
    public override func getFilterQueries(request: R?) -> String? {
        return nil
    }
}


