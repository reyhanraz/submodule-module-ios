//
//  ArtisanService+SQL.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 25/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform
import ServiceWrapper

extension ArtisanService: MultiTableRecord {
    public typealias R = ServiceListRequest
    
    public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.title] = title
        container[Columns.description] = description
        container[Columns.status] = status.stringValue
        container[Columns.duration] = duration
        container[Columns.price] = price
        container[Columns.originalPrice] = originalPrice
        container[Columns.category] = categoryData
        container[Columns.images] = imagesData
        container[Columns.artisan] = artisan
        container[Columns.topParentId] = topParent?.id
        container[CommonColumns.timestamp] = timeStamp
    }
    
    public var contentValues: [String : DatabaseValueConvertible?] {
        return [
            ArtisanService.Columns.id.rawValue: id,
            ArtisanService.Columns.title.rawValue: title,
            ArtisanService.Columns.description.rawValue: description,
            ArtisanService.Columns.status.rawValue: status.stringValue,
            ArtisanService.Columns.duration.rawValue: duration,
            ArtisanService.Columns.price.rawValue: price,
            ArtisanService.Columns.originalPrice.rawValue: originalPrice,
            ArtisanService.Columns.category.rawValue: categoryData,
            ArtisanService.Columns.images.rawValue: imagesData,
            ArtisanService.Columns.artisan.rawValue: artisan,
            ArtisanService.Columns.topParentId.rawValue: topParent?.id,
            CommonColumns.timestamp.rawValue: timeStamp,

        ]
    }
    
    public func update(_ db: Database) throws {
        let columns = columnNamesForUpdate
        
        let statement = "UPDATE \(ArtisanService.databaseTableName) SET \(columns) WHERE \(CommonColumns.id.rawValue) = :\(CommonColumns.id.rawValue)"
        
        try db.execute(sql: statement, arguments: StatementArguments(contentValues))
        
    }
    
    public func insert(_ db: Database) throws {
        try performInsert(db)
        
    }
    
    public static func fetchAll(_ db: Database, request: R?) throws -> [ArtisanService] {
        
        let query = getQueryStatement(request: request, tableName: ArtisanService.databaseTableName)
        
        let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(ArtisanService.databaseTableName) \(query)")
        return try rows.map { row in
            let decoder = JSONDecoder()
            let category = try decoder.decode(Category.self, from: row[ArtisanService.Columns.category])
            let imageMedia = try decoder.decode([Media].self, from: row[ArtisanService.Columns.images])
            return ArtisanService(id: row[ArtisanService.Columns.id],
                                  title: row[ArtisanService.Columns.title],
                                  description: row[ArtisanService.Columns.description],
                                  status: ItemStatus(string: row[ArtisanService.Columns.status]),
                                  duration: row[ArtisanService.Columns.duration],
                                  price: row[ArtisanService.Columns.price],
                                  originalPrice: row[ArtisanService.Columns.originalPrice],
                                  category: category,
                                  images: imageMedia,
                                  artisan: row[ArtisanService.Columns.artisan],
                                  timeStamp: row[CommonColumns.timestamp],
                                  paging: nil)
        }
    }
    
    
    public static func getQueryStatement(request: R?, tableName: String) -> String {
        var query = "WHERE \(tableName).\(CommonColumns._id.rawValue) != -1"
        if let artisanID = request?.artisan {
            query += " AND \(ArtisanService.Columns.artisan.rawValue) == '\(artisanID)'"
        }
        
        if let category = request?.category {
            query += " AND \(ArtisanService.Columns.topParentId.rawValue) == \(category)"
        }        
        return query
    }
}



