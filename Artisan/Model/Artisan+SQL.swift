//
//  Artisan+SQL.swift
//  Artisan
//
//  Created by Fandy Gotama on 07/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform
import ServiceWrapper

extension Artisan: MultiTableRecord {
    public typealias R = ArtisanFilter

    public var contentValues: [String : DatabaseValueConvertible?] {

        let params: [String : DatabaseValueConvertible?] = [
            Artisan.Columns.id.rawValue: id,
            Artisan.Columns.email.rawValue: email,
            Artisan.Columns.name.rawValue: name,
            Artisan.Columns.phoneNumber.rawValue: phoneNumber,
            Artisan.Columns.username.rawValue: username,
            Artisan.Columns.facebookID.rawValue: facebookID,
            Artisan.Columns.googleID.rawValue: googleID,
            Artisan.Columns.appleID.rawValue: appleID,
            Artisan.Columns.metadata.rawValue: metadataData,
            Artisan.Columns.favorite.rawValue: favorite,
            Artisan.Columns.jobDone.rawValue: jobDone,
            Artisan.Columns.rating.rawValue: rating,
            Artisan.Columns.category.rawValue: categoryData,
            Artisan.Columns.avatar.rawValue: avatarData,
            Artisan.Columns.status.rawValue: status,
            CommonColumns.timestamp.rawValue: timeStamp,
            Artisan.Columns.created_at.rawValue: created_at,
        ]

        return params
    }

    func insert(_ db: Database, tableName: String) throws {
        let columns = columnNamesAndKeys

        let statement = "INSERT INTO \(tableName) (\(columns.names)) VALUES (\(columns.keys))"

        try db.execute(sql: statement, arguments: StatementArguments(contentValues))

        
    }

    func update(_ db: Database, tableName: String) throws {
        let columns = columnNamesForUpdate

        let statement = "UPDATE \(tableName) SET \(columns) WHERE \(CommonColumns.id.rawValue) = :\(CommonColumns.id.rawValue)"

        try db.execute(sql: statement, arguments: StatementArguments(contentValues))
    }

    static func fetchAll(_ db: Database, request: R?, tableName: String) throws -> [Artisan] {
        let query = getQueryStatement(request: request, tableName: tableName)
//        let order = getOrderStatement(request: request, tableName: tableName)

        let rows = try Row.fetchAll(db, sql:
        """
        SELECT * FROM \(tableName) \(query) 
        """)
        
        let decoder = JSONDecoder()

        return rows.map { row in
            let metadata = try? decoder.decode([Artisan.Metadata].self, from: row[Artisan.Columns.metadata])
            let category = try? decoder.decode([Artisan.Category].self, from: row[Artisan.Columns.category])
            let avatar = try? decoder.decode(Media.self, from: row[Artisan.Columns.avatar])

            
            let artisan = Artisan(id: row[Artisan.Columns.id],
                                  email: row[Artisan.Columns.email],
                                  name: row[Artisan.Columns.name],
                                  phoneNumber: row[Artisan.Columns.phoneNumber],
                                  username: row[Artisan.Columns.username] ?? "",
                                  facebookID: row[Artisan.Columns.facebookID],
                                  googleID: row[Artisan.Columns.googleID],
                                  appleID: row[Artisan.Columns.appleID],
                                  type: .artisan,
                                  metadata: metadata,
                                  favorite: row[Artisan.Columns.favorite],
                                  jobDone: row[Artisan.Columns.jobDone],
                                  rating: row[Artisan.Columns.rating],
                                  category: category,
                                  avatar: avatar,
                                  isVerified: row[Artisan.Columns.isVerified],
                                  status: row[Artisan.Columns.status],
                                  hasAddress: false,
                                  categories: nil,
                                  instagram: nil,
                                  birthdate: nil,
                                  idCard: nil,
                                  bio: nil,
                                  timeStamp: row[CommonColumns.timestamp],
                                  createdAt: row[Artisan.Columns.created_at])
            
            return artisan
        }
    }

    public static func getQueryStatement(request: R?, tableName: String) -> String {
        var query = "WHERE \(tableName).\(CommonColumns._id.rawValue) != -1"

        if let request = request {
            if let id = request.id {
                query += " AND  \(tableName).\(CommonColumns.id.rawValue) = '\(id)'"
            }

//            if request.page > 0 && !request.ignorePaging {
//                query += " AND \(Paging.Columns.currentPage.rawValue) = \(request.page)"
//            }
        }

        return query
    }

    public static func getOrderStatement(request: R?, tableName: String) -> String {
        let order = "ORDER BY \(tableName).\(Paging.Columns.currentPage.rawValue) ASC"

        return order
    }
}
