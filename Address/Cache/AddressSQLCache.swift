//
//  AddressSQLCache.swift
//  Address
//
//  Created by Fandy Gotama on 30/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform
//Temporary disable cache
public class AddressSQLCache<R>: SQLCache<R, Address> {
    
    public override init(dbQueue: DatabaseQueue, expiredAfter: TimeInterval = CacheExpiryDate.oneMonth.rawValue) {
        super.init(dbQueue: dbQueue, expiredAfter: expiredAfter)
    }
    
    public static func createTable(db: Database) throws {
        try db.create(table: Address.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(Address.Columns.id.rawValue, .integer).unique(onConflict: .replace)
            body.column(Address.Columns.user.rawValue, .text)
            body.column(Address.Columns.address.rawValue, .text)
            body.column(Address.Columns.name.rawValue, .text)
            body.column(Address.Columns.notes.rawValue, .text)
            body.column(Address.Columns.latitude.rawValue, .double)
            body.column(Address.Columns.longitude.rawValue, .double)
            body.column(CommonColumns.timestamp.rawValue, .integer)
        }
    }
    
    public static func dropTable(db: Database) throws{
        try db.execute(sql: """
            DROP TABLE IF EXISTS \(Address.databaseTableName);
        """)
    }
    
    public override func getList(request: R? = nil) -> [Address] {
        do {
            let list = try dbQueue.read({ db in
                try Address.order(CommonColumns.id.asc).fetchAll(db)
            })
            
            return list
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
        
        return []
    }
    
    public override func update(model: Address) -> Bool {
        do {
            try dbQueue.write { db in
                try model.update(db)
            }
            
            return true
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
        
        return false
    }
    
    public override func put(model: Address) {
        putList(models: [model])
    }
    
    public override func putList(models: [Address]) {
        do {
            try dbQueue.inTransaction { db in
                
                for record in models {
                    try record.insert(db)
                }
                
                return .commit
            }
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    public override func remove(model: Address) {
        do {
            let _ = try dbQueue.write { db in
                try Address.deleteOne(db, key: [Address.Columns.id.rawValue: model.id])
            }
        } catch let error {
            assertionFailure(error.localizedDescription)
        }
    }
    
    public override func getFilterQueries(request: R?) -> String? {
        return nil
    }
}


