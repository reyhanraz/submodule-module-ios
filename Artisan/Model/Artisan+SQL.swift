//
//  Artisan+SQL.swift
//  Artisan
//
//  Created by Fandy Gotama on 07/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

extension Artisan: MultiTableRecord {
    public typealias R = ArtisanFilter

    public var contentValues: [String : DatabaseValueConvertible?] {

        var params: [String : DatabaseValueConvertible?] = [
            Artisan.Columns.id.rawValue: id,
            Artisan.Columns.name.rawValue: name,
            Artisan.Columns.email.rawValue: email,
            Artisan.Columns.phone.rawValue: phone,
            Artisan.Columns.dob.rawValue: dob,
            Artisan.Columns.about.rawValue: about,
            Artisan.Columns.avatar.rawValue: avatar?.url,
            Artisan.Columns.avatarServingURL.rawValue: avatar?.servingURL,
            Artisan.Columns.hasReview.rawValue: hasReview,
            Artisan.Columns.status.rawValue: status.stringValue,
            Artisan.Columns.createdAt.rawValue: createdAt.timeIntervalSince1970,
            Artisan.Columns.updatedAt.rawValue: createdAt.timeIntervalSince1970,
            Artisan.Columns.gender.rawValue: gender?.rawValue,
            Artisan.Columns.reviewRating.rawValue: reviewRating,
            Artisan.Favorite.Columns.count.rawValue: favorite?.count,
            Artisan.Favorite.Columns.isFavorite.rawValue: favorite?.isFavorite,
            Artisan.Columns.emailConfirmed.rawValue: emailConfirmed,
            Artisan.Columns.instagram.rawValue: instagram,
            Artisan.Columns.distance.rawValue: distance,
            CommonColumns.timestamp.rawValue: timestamp
        ]

        if let paging = paging {
            params[Paging.Columns.currentPage.rawValue] = paging.currentPage
            params[Paging.Columns.limitPerPage.rawValue] = paging.limitPerPage
            params[Paging.Columns.totalPage.rawValue] = paging.totalPage
        }

        return params
    }

    func insert(_ db: Database, tableName: String) throws {
        let columns = columnNamesAndKeys

        let statement = "INSERT INTO \(tableName) (\(columns.names)) VALUES (\(columns.keys))"

        try db.execute(sql: statement, arguments: StatementArguments(contentValues))

        try services?.forEach {
            try db.execute(sql:
            """
            INSERT INTO \(tableName)\(TableNames.Artisan.Relation.service) (
            \(CommonColumns.fkId.rawValue), \(Artisan.Service.Columns.id.rawValue),
            \(Artisan.Service.Columns.title.rawValue), \(Artisan.Service.Columns.cover.rawValue), 
            \(Artisan.Service.Columns.coverServingURL.rawValue)
            )
            VALUES (?, ?, ?, ?, ?)
            """, arguments: [id, $0.id, $0.title, $0.cover.url, $0.cover.servingURL])
        }

        try categories?.forEach {
            try db.execute(sql:
            """
            INSERT INTO \(tableName)\(TableNames.Artisan.Relation.category) (
            \(CommonColumns.fkId.rawValue), \(Artisan.Category.Columns.id.rawValue),
            \(Artisan.Category.Columns.title.rawValue)
            )
            VALUES (?, ?, ?)
            """, arguments: [id, $0.id, $0.name])
        }

        try categoryTypes?.forEach {
            try db.execute(sql:
            """
            INSERT INTO \(tableName)\(TableNames.Artisan.Relation.categoryType) (
            \(CommonColumns.fkId.rawValue), \(Artisan.CategoryType.Columns.id.rawValue),
            \(Artisan.CategoryType.Columns.serviceCategoryId.rawValue), \(Artisan.CategoryType.Columns.title.rawValue)
            )
            VALUES (?, ?, ?, ?)
            """, arguments: [id, $0.id, $0.serviceCategoryId, $0.name])
        }
    }

    func update(_ db: Database, tableName: String) throws {
        let columns = columnNamesForUpdate

        let statement = "UPDATE \(tableName) SET \(columns) WHERE \(CommonColumns.id.rawValue) = :\(CommonColumns.id.rawValue)"

        try db.execute(sql: statement, arguments: StatementArguments(contentValues))
    }

    static func fetchAll(_ db: Database, request: R?, tableName: String) throws -> [Artisan] {
        let query = getQueryStatement(request: request, tableName: tableName)
        let order = getOrderStatement(request: request, tableName: tableName)

        let rows = try Row.fetchAll(db, sql:
        """
        SELECT * FROM \(tableName) \(query) \(order)
        """)

        return try rows.map { row in
            let pkId = row[CommonColumns.id]

            let serviceRows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName)\(TableNames.Artisan.Relation.service) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [pkId])

            let services = serviceRows.map { service -> Artisan.Service in
                let coverServingURL: URL?

                if let url = service[Artisan.Service.Columns.coverServingURL] as? String {
                    coverServingURL = URL(string: url)
                } else {
                    coverServingURL = nil
                }

                return Artisan.Service(
                    id: service[Artisan.Service.Columns.id],
                    title: service[Artisan.Service.Columns.title],
                    cover: Media(url: URL(string: service[Artisan.Service.Columns.cover])!, servingURL: coverServingURL),
                    coverServingURL: coverServingURL)
            }

            let categoryRows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName)\(TableNames.Artisan.Relation.category) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [pkId])

            let categories = categoryRows.map {

                Artisan.Category(
                    id: $0[Artisan.Category.Columns.id],
                    name: $0[Artisan.Category.Columns.title])
            }

            let categoryTypeRows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName)\(TableNames.Artisan.Relation.categoryType) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [pkId])

            let categoryTypes = categoryTypeRows.map {

                Artisan.CategoryType(
                    id: $0[Artisan.CategoryType.Columns.id],
                    serviceCategoryId: $0[Artisan.CategoryType.Columns.serviceCategoryId],
                    name: $0[Artisan.CategoryType.Columns.title])
            }

            let paging = Paging(currentPage: row[Paging.Columns.currentPage] ?? 1,
                limitPerPage: row[Paging.Columns.limitPerPage] ?? 1,
                totalPage: row[Paging.Columns.totalPage] ?? 1)

            let media: URL?

            if let avatar = row[Artisan.Columns.avatar] as? String, let avatarURL = URL(string: avatar) {
                media = avatarURL
            } else {
                media = nil
            }

            let servingMedia: URL?

            if let avatar = row[Artisan.Columns.avatarServingURL] as? String, let avatarServingURL = URL(string: avatar) {
                servingMedia = avatarServingURL
            } else {
                servingMedia = nil
            }

            let favorite: Artisan.Favorite?

            if let _ = row[Artisan.Favorite.Columns.count], let _ = row[Artisan.Favorite.Columns.isFavorite] {
                favorite = Artisan.Favorite(count: row[Artisan.Favorite.Columns.count], isFavorite: row[Artisan.Favorite.Columns.isFavorite])
            } else {
                favorite = nil
            }

            let booking: Artisan.Booking?

            if let _ = row[Artisan.Booking.Columns.count] {
                booking = Artisan.Booking(count: row[Artisan.Booking.Columns.count])
            } else {
                booking = nil
            }

            return Artisan(
                id: row[Artisan.Columns.id],
                email: row[Artisan.Columns.email],
                name: row[Artisan.Columns.name],
                phone: row[Artisan.Columns.phone],
                verified: nil,
                avatar: media,
                avatarServingURL: servingMedia,
                gender: row[Artisan.Columns.gender] as? String,
                dob: row[Artisan.Columns.dob] as? TimeInterval,
                reviewRating: row[Artisan.Columns.reviewRating],
                status: row[Artisan.Columns.status],
                createdAt: row[Artisan.Columns.createdAt] as TimeInterval,
                updatedAt: row[Artisan.Columns.updatedAt] as TimeInterval,
                emailConfirmed: row[Artisan.Columns.emailConfirmed],
                instagram: row[Artisan.Columns.instagram],
                about: row[Artisan.Columns.about],
                level: row[Artisan.Columns.level],
                services: services,
                categories: categories,
                categoryTypes: categoryTypes,
                favorite: favorite,
                booking: booking,
                distance: row[Artisan.Columns.distance],
                identityCardNumber: nil,
                identityCardURL: nil,
                identityCardServingURL: nil,
                hasReview: row[Artisan.Columns.hasReview],
                paging: paging)
        }
    }

    public static func getQueryStatement(request: R?, tableName: String) -> String {
        var query = "WHERE \(tableName).\(CommonColumns._id.rawValue) != -1"

        if let request = request {
            if let id = request.id, id > 0 {
                query += " AND  \(tableName).\(CommonColumns.id.rawValue) = \(id)"
            }

            if request.page > 0 && !request.ignorePaging {
                query += " AND \(Paging.Columns.currentPage.rawValue) = \(request.page)"
            }
        }

        return query
    }

    public static func getOrderStatement(request: R?, tableName: String) -> String {
        let order = "ORDER BY \(tableName).\(Paging.Columns.currentPage.rawValue) ASC"

        return order
    }
}
