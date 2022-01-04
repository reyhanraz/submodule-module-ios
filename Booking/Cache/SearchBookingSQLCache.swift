//
//  SearchBookingSQLCache.swift
//  Booking
//
//  Created by Fandy Gotama on 26/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class SearchBookingSQLCache: BookingSQLCache {
    
    private let _dbQueue: DatabaseQueue
    private let _tableName: String
    private let _expiredAfter: TimeInterval
    
    public override init(dbQueue: DatabaseQueue, tableName: String, expiredAfter: TimeInterval = CacheExpiryDate.oneDay.rawValue) {
        _dbQueue = dbQueue
        _tableName = tableName
        _expiredAfter = expiredAfter
        
        super.init(dbQueue: _dbQueue, tableName: _tableName, expiredAfter: _expiredAfter)
    }
    
    public override func getList(request: BookingListRequest?) -> [Booking] {
        do {
            let list = try _dbQueue.read({ db in
                try Booking.fetchAll(db, request: request, tableName: _tableName)
            })
            
            if list.count > CacheConfig.maxSearchLimit {
                let _ = try _dbQueue.write { db in
                    try Booking.delete(db, request: request, tableName: _tableName)
                }
            }
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
}
