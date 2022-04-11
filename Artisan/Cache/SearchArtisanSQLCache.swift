//
//  SearchArtisanSQLCache.swift
//  Artisan
//
//  Created by Fandy Gotama on 17/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform
import ServiceWrapper

public class SearchArtisanSQLCache: ArtisanSQLCache {
    
    private let _dbQueue: DatabaseQueue
    private let _tableName: String
    private let _expiredAfter: TimeInterval
    
    public override init(dbQueue: DatabaseQueue, tableName: String, expiredAfter: TimeInterval = CacheExpiryDate.oneDay.rawValue) {
        _dbQueue = dbQueue
        _tableName = tableName
        _expiredAfter = expiredAfter
        
        super.init(dbQueue: _dbQueue, tableName: _tableName, expiredAfter: _expiredAfter)
    }
    
    public override func getList(request: ArtisanFilter?) -> [Artisan] {
        do {
            let list = try _dbQueue.read({ db in
                try Artisan.fetchAll(db, request: request, tableName: _tableName)
            })
            
            if list.count > CacheConfig.maxSearchLimit {
                let _ = try _dbQueue.write { db in
                    try Artisan.delete(db, request: request, tableName: _tableName)
                }
            }
            
            return list
        } catch {
            assertionFailure()
        }
        
        return []
    }
}
