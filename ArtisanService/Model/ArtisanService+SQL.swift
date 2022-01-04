//
//  ArtisanService+SQL.swift
//  ArtisanService
//
//  Created by Fandy Gotama on 25/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

extension ArtisanService: MultiTableRecord {
    public typealias R = ListRequest
    
    public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.artisanId] = artisanId
        container[Columns.title] = title
        container[Columns.description] = description
        container[Columns.price] = "\(price)"
        container[Columns.status] = status.stringValue
        container[Columns.cover] = cover.url
        container[Columns.coverServingURL] = cover.servingURL
        container[Paging.Columns.currentPage] = paging?.currentPage ?? 1
        container[Paging.Columns.limitPerPage] = paging?.limitPerPage ?? PlatformConfig.defaultLimit
        container[Paging.Columns.totalPage] = paging?.totalPage ?? 1
        
        container[CommonColumns.timestamp] = timestamp
    }
    
    public var contentValues: [String : DatabaseValueConvertible?] {
        return [
            ArtisanService.Columns.id.rawValue: id,
            ArtisanService.Columns.artisanId.rawValue: artisanId,
            ArtisanService.Columns.title.rawValue: title,
            ArtisanService.Columns.description.rawValue: description,
            ArtisanService.Columns.price.rawValue: "\(price)",
            ArtisanService.Columns.status.rawValue: status.stringValue,
            ArtisanService.Columns.cover.rawValue: cover.url,
            ArtisanService.Columns.coverServingURL.rawValue: cover.servingURL
        ]
    }
    
    public func update(_ db: Database) throws {
        let columns = columnNamesForUpdate
        
        let statement = "UPDATE \(ArtisanService.databaseTableName) SET \(columns) WHERE \(CommonColumns.id.rawValue) = :\(CommonColumns.id.rawValue)"
        
        try db.execute(sql: statement, arguments: StatementArguments(contentValues))
        
        try db.execute(sql: "DELETE FROM \(ArtisanService.ServiceType.databaseTableName) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        try db.execute(sql: "DELETE FROM \(ArtisanService.ServiceTag.databaseTableName) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        
        try updateRelations(db)
    }
    
    public func insert(_ db: Database) throws {
        try performInsert(db)
        
        try updateRelations(db)
    }
    
    public static func fetchAll(_ db: Database, request: R?) throws -> [ArtisanService] {
        
        let query = getQueryStatement(request: request, tableName: ArtisanService.databaseTableName)
        
        let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(ArtisanService.databaseTableName) \(query)")
        
        return try rows.map { row in
            let id = row[ArtisanService.Columns.id]
            
            let itemRows = try Row.fetchAll(db, sql: "SELECT * FROM \(ArtisanService.ServiceType.databaseTableName) WHERE \(CommonColumns.fkId.rawValue) = ? ORDER BY _id ASC", arguments: [id])
            
            let items = itemRows.map { itemRow in
                ServiceType(id: itemRow[ArtisanService.ServiceType.Columns.id],
                            serviceCategoryId: itemRow[ArtisanService.ServiceType.Columns.serviceCategoryId],
                            name: itemRow[ArtisanService.ServiceType.Columns.name])
            }
            
            let tagRows = try Row.fetchAll(db, sql: "SELECT * FROM \(ArtisanService.ServiceTag.databaseTableName) WHERE \(CommonColumns.fkId.rawValue) = ? ORDER BY _id ASC", arguments: [id])
            
            let tags = tagRows.compactMap { $0[ArtisanService.ServiceTag.Columns.tag] as? String }
            
            let cover: Media
            let coverServingURL: URL?

            if let image = row[ArtisanService.Columns.coverServingURL] as? String, let url = URL(string: image) {
                coverServingURL = url
            } else {
                coverServingURL = nil
            }

            if let image = row[ArtisanService.Columns.cover] as? String, let url = URL(string: image) {
                cover = Media(url: url, servingURL: coverServingURL)
            } else {
                fatalError()
            }
            
            return ArtisanService(
                id: row[ArtisanService.Columns.id],
                artisanId: row[ArtisanService.Columns.artisanId],
                title: row[ArtisanService.Columns.title],
                description: row[ArtisanService.Columns.description],
                price: Decimal(string: row[ArtisanService.Columns.price]) ?? 0,
                status: ItemStatus(string: row[ArtisanService.Columns.status]),
                cover: cover,
                coverServingURL: coverServingURL,
                serviceTypes: items,
                tags: tags)
        }
    }
    
    
    public static func getQueryStatement(request: R?, tableName: String) -> String {
        var query = "WHERE \(tableName).\(CommonColumns._id.rawValue) != -1"
        
        if let request = request, request.page > 0 && !request.ignorePaging {
            query += " AND \(Paging.Columns.currentPage.rawValue) = \(request.page)"
        }
        
        if let id = request?.id, id > 0 {
            query += " AND \(tableName).\(ArtisanService.Columns.artisanId.rawValue) = \(id)"
        }
        
        return query
    }
    
    private func updateRelations(_ db: Database) throws {
        try serviceTypes.forEach {
            try db.execute(sql: """
                INSERT INTO \(ArtisanService.ServiceType.databaseTableName)
                (\(CommonColumns.fkId.rawValue), \(Columns.id.rawValue), \(ServiceType.Columns.serviceCategoryId), \(ServiceType.Columns.name.rawValue))
                VALUES (?, ?, ?, ?)
                """, arguments: [id, $0.id, $0.serviceCategoryId, $0.name])
        }
        
        try tags?.forEach {
            try db.execute(sql: """
                INSERT INTO \(ArtisanService.ServiceTag.databaseTableName)
                (\(CommonColumns.fkId.rawValue), \(ServiceTag.Columns.tag.rawValue))
                VALUES (?, ?)
                """, arguments: [id, $0])
        }
    }
}



