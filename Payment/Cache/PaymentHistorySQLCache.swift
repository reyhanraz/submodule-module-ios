//
//  PaymentHistorySQLCache.swift
//  Payment
//
//  Created by Fandy Gotama on 28/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class PaymentHistorySQLCache<R>: SQLCache<R, PaymentHistory> {
    
    public override init(dbQueue: DatabaseQueue, expiredAfter: TimeInterval = CacheExpiryDate.oneMonth.rawValue) {
        super.init(dbQueue: dbQueue, expiredAfter: expiredAfter)
    }
    
    public static func createTable(db: Database) throws {
        try db.create(table: PaymentHistory.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.id.rawValue, .integer).unique().notNull()
            body.column(PaymentHistory.Columns.context.rawValue, .text).notNull()
            body.column(PaymentHistory.Columns.amount.rawValue, .text).notNull()
            body.column(PaymentHistory.Columns.status.rawValue, .text).notNull()
            body.column(PaymentHistory.Columns.transactionType.rawValue, .text).notNull()
            body.column(PaymentHistory.Columns.createdAt.rawValue, .integer).notNull()
            body.column(Paging.Columns.currentPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.limitPerPage.rawValue, .integer).notNull()
            body.column(Paging.Columns.totalPage.rawValue, .integer).notNull()
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
    }
    
    public override func getList(request: R? = nil) -> [PaymentHistory] {
        do {
            let list = try dbQueue.read { db -> [PaymentHistory] in
                try PaymentHistory.fetchAll(db)
            }
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public override func put(model: PaymentHistory) {
        putList(models: [model])
    }
    
    public override func putList(models: [PaymentHistory]) {
        let timestamp = Date().timeIntervalSince1970
        
        do {
            try dbQueue.inTransaction { db in
                
                for record in models {
                    record.timestamp = timestamp
                    
                    try record.insert(db)
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



