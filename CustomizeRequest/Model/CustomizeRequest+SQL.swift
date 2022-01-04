//
//  CustomizeRequest+SQL.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 06/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

extension CustomizeRequest: MultiTableRecord {
    public typealias R = CustomizeListRequest

    public func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.status] = status.rawValue
        container[Columns.eventName] = eventName
        container[Columns.start] = start.timeIntervalSince1970
        container[Columns.totalPrice] = "\(totalPrice)"
        container[Columns.createdAt] = createdAt.timeIntervalSince1970
        container[Columns.updatedAt] = updatedAt.timeIntervalSince1970
        container[Columns.notes] = notes
        container[CommonColumns.timestamp] = timestamp

        if let paging = paging {
            container[Paging.Columns.currentPage] = paging.currentPage
            container[Paging.Columns.limitPerPage] = paging.limitPerPage
            container[Paging.Columns.totalPage] = paging.totalPage
        }
    }

    public var contentValues: [String : DatabaseValueConvertible?] {
        return [
            Columns.id.rawValue: id,
            Columns.status.rawValue: status.rawValue
        ]
    }

    public func insert(_ db: Database) throws {
        try performInsert(db)

        try updateRelations(db)
    }

    public func update(_ db: Database) throws {
        let columns = columnNamesForUpdate

        let statement = "UPDATE \(CustomizeRequest.databaseTableName) SET \(columns) WHERE \(CustomizeRequest.Columns.id.rawValue) = :\(CustomizeRequest.Columns.id.rawValue)"

        try db.execute(sql: statement, arguments: StatementArguments(contentValues))

    }

    public static func fetchAll(_ db: Database, request: CustomizeListRequest?) throws -> [CustomizeRequest] {
        let query = getQueryStatement(request: request, tableName: CustomizeRequest.databaseTableName)

        let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(CustomizeRequest.databaseTableName) \(query)")

        return try rows.map { row in
            let id = row[CustomizeRequest.Columns.id]

            guard
                    let customerRow = try Row.fetchOne(db, sql: "SELECT * FROM \(CustomizeRequest.databaseTableName)\(TableNames.CustomizeRequest.customer) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id]),
                    let addressRow = try Row.fetchOne(db, sql: "SELECT * FROM \(CustomizeRequest.databaseTableName)\(TableNames.CustomizeRequest.address) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
                    else { fatalError() }

            let customerAvatar: URL?

            if let avatar = customerRow[User.Columns.avatar] as? String {
                customerAvatar = URL(string: avatar)
            } else {
                customerAvatar = nil
            }

            let artisan: Artisan?

            if let artisanRow = try Row.fetchOne(db, sql: "SELECT * FROM \(CustomizeRequest.databaseTableName)\(TableNames.CustomizeRequest.artisan) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id]) {
                artisan = Artisan.get(db: db, row: artisanRow)
            } else {
                artisan = nil
            }

            let customer = User(
                    id: customerRow[User.Columns.id],
                    email: customerRow[User.Columns.email],
                    name: customerRow[User.Columns.name],
                    phone: customerRow[User.Columns.phone],
                    avatar: customerAvatar,
                    gender: customerRow[User.Columns.gender],
                    dob: customerRow[User.Columns.dob],
                    status: customerRow[User.Columns.status],
                    createdAt: customerRow[User.Columns.createdAt],
                    updatedAt: customerRow[User.Columns.updatedAt],
                    emailConfirmed: customerRow[User.Columns.emailConfirmed])

            let address = Address(
                    id: addressRow[Address.Columns.id],
                    userId: addressRow[Address.Columns.userId],
                    provinceId: addressRow[Address.Columns.provinceId],
                    districtId: addressRow[Address.Columns.districtId],
                    areaId: addressRow[Address.Columns.areaId],
                    name: addressRow[Address.Columns.name],
                    detail: addressRow[Address.Columns.detail],
                    provinceName: addressRow[Address.Columns.provinceName],
                    districtName: addressRow[Address.Columns.districtName],
                    districtType: addressRow[Address.Columns.districtType],
                    subDistrictName: addressRow[Address.Columns.subDistrictName],
                    urbanVillageName: addressRow[Address.Columns.urbanVillageName],
                    postalCode: addressRow[Address.Columns.postalCode],
                    timestamp: nil)

            let serviceRows = try Row.fetchAll(db, sql: "SELECT * FROM \(CustomizeRequest.CustomizeRequestService.databaseTableName) WHERE \(CommonColumns.fkId.rawValue) = ? ORDER BY _id ASC", arguments: [id])

            let items = serviceRows.map { serviceRow -> CustomizeRequestService in
                return CustomizeRequestService(
                        customRequestId: row[CustomizeRequest.Columns.id],
                        serviceId: serviceRow[CustomizeRequestService.Columns.serviceId],
                        title: serviceRow[CustomizeRequestService.Columns.title],
                        price: Decimal(string: serviceRow[CustomizeRequestService.Columns.price]) ?? 0,
                        quantity: serviceRow[CustomizeRequestService.Columns.quantity],
                        updatedAt: serviceRow[CustomizeRequestService.Columns.updatedAt])

            }

            let paging = Paging(currentPage: row[Paging.Columns.currentPage] ?? 1,
                    limitPerPage: row[Paging.Columns.limitPerPage] ?? PlatformConfig.defaultLimit,
                    totalPage: row[Paging.Columns.totalPage] ?? 1)

            return CustomizeRequest(
                    id: row[CustomizeRequest.Columns.id],
                    status: CustomizeRequest.Status(rawValue: row[CustomizeRequest.Columns.status]) ?? .open,
                    eventName: row[CustomizeRequest.Columns.eventName],
                    start: Date(timeIntervalSince1970: row[CustomizeRequest.Columns.start]),
                    totalPrice: Decimal(string: row[CustomizeRequest.Columns.totalPrice]) ?? 0,
                    createdAt: Date(timeIntervalSince1970: row[CustomizeRequest.Columns.createdAt]),
                    updatedAt: Date(timeIntervalSince1970: row[CustomizeRequest.Columns.updatedAt]),
                    notes: row[CustomizeRequest.Columns.notes],
                    customer: customer,
                    artisan: artisan,
                    address: address,
                    bookingServices: items,
                    paging: paging,
                    timestamp: row[CommonColumns.timestamp])
        }
    }

    public static func getQueryStatement(request: CustomizeListRequest?, tableName: String) -> String {
        var query = "WHERE \(tableName).\(CommonColumns._id.rawValue) != -1"

        if let request = request {
            if request.page > 0 && !request.ignorePaging {
                query += " AND \(Paging.Columns.currentPage.rawValue) = \(request.page)"
            } else if let id = request.id {
                query += " AND \(CustomizeRequest.Columns.id.rawValue) = \(id)"
            }
        }

        return query
    }

    private func updateRelations(_ db: Database) throws {
        func getColumnsAndKeys(values: [String : DatabaseValueConvertible?]) -> (names: String, keys: String) {
            var columnNames = ""
            var columnKeys = ""

            values.forEach { (key, value) in
                columnNames += "\(key),"
                columnKeys += ":\(key),"
            }

            return (names: String(columnNames.dropLast()), keys: String(columnKeys.dropLast()))
        }

        var customerValues: [String : DatabaseValueConvertible?] {
            return [
                CommonColumns.fkId.rawValue: id,
                User.Columns.id.rawValue: customer.id,
                User.Columns.email.rawValue: customer.email,
                User.Columns.name.rawValue: customer.name,
                User.Columns.phone.rawValue: customer.phone,
                User.Columns.status.rawValue: customer.status.stringValue,
                User.Columns.createdAt.rawValue: customer.createdAt.timeIntervalSince1970,
                User.Columns.updatedAt.rawValue: customer.updatedAt.timeIntervalSince1970,
                User.Columns.dob.rawValue: customer.dob?.timeIntervalSince1970,
                User.Columns.gender.rawValue: customer.gender?.rawValue,
                User.Columns.avatar.rawValue: customer.avatar?.url,
                User.Columns.emailConfirmed.rawValue: customer.emailConfirmed
            ]
        }

        var addressValues: [String : DatabaseValueConvertible?] {
            return [
                CommonColumns.fkId.rawValue: id,
                Address.Columns.id.rawValue: address.id,
                Address.Columns.userId.rawValue: address.userId,
                Address.Columns.provinceId.rawValue: address.provinceId,
                Address.Columns.districtId.rawValue: address.districtId,
                Address.Columns.areaId.rawValue: address.areaId,
                Address.Columns.name.rawValue: address.name,
                Address.Columns.detail.rawValue: address.detail,
                Address.Columns.provinceName.rawValue: address.provinceName,
                Address.Columns.districtName.rawValue: address.districtName,
                Address.Columns.districtType.rawValue: address.districtType,
                Address.Columns.subDistrictName.rawValue: address.subDistrictName,
                Address.Columns.urbanVillageName.rawValue: address.urbanVillageName,
                Address.Columns.postalCode.rawValue: address.postalCode
            ]
        }

        if let artisan = artisan {
            var artisanValues: [String : DatabaseValueConvertible?] {
                return [
                    CommonColumns.fkId.rawValue: id,
                    Artisan.Columns.id.rawValue: artisan.id,
                    Artisan.Columns.email.rawValue: artisan.email,
                    Artisan.Columns.name.rawValue: artisan.name,
                    Artisan.Columns.phone.rawValue: artisan.phone,
                    Artisan.Columns.status.rawValue: artisan.status.stringValue,
                    Artisan.Columns.createdAt.rawValue: artisan.createdAt.timeIntervalSince1970,
                    Artisan.Columns.updatedAt.rawValue: artisan.updatedAt.timeIntervalSince1970,
                    Artisan.Columns.dob.rawValue: artisan.dob?.timeIntervalSince1970,
                    Artisan.Columns.gender.rawValue: artisan.gender?.rawValue,
                    Artisan.Columns.avatar.rawValue: artisan.avatar?.url,
                    Artisan.Columns.instagram.rawValue: artisan.instagram,
                    Artisan.Columns.distance.rawValue: artisan.distance,
                    Artisan.Favorite.Columns.count.rawValue: artisan.favorite?.count,
                    Artisan.Favorite.Columns.isFavorite.rawValue: artisan.favorite?.isFavorite,
                    Artisan.Booking.Columns.count.rawValue: artisan.booking?.count,
                    Artisan.Columns.reviewRating.rawValue: artisan.reviewRating,
                    Artisan.Columns.about.rawValue: artisan.about,
                    Artisan.Columns.emailConfirmed.rawValue: artisan.emailConfirmed
                ]
            }

            let artisanColumns = getColumnsAndKeys(values: artisanValues)
            let artisanStatement = "INSERT INTO \(CustomizeRequest.databaseTableName)\(TableNames.CustomizeRequest.artisan) (\(artisanColumns.names)) VALUES (\(artisanColumns.keys))"
            try db.execute(sql: artisanStatement, arguments: StatementArguments(artisanValues))
        }

        let customerColumns = getColumnsAndKeys(values: customerValues)
        let customerStatement = "INSERT INTO \(CustomizeRequest.databaseTableName)\(TableNames.CustomizeRequest.customer) (\(customerColumns.names)) VALUES (\(customerColumns.keys))"
        try db.execute(sql: customerStatement, arguments: StatementArguments(customerValues))

        let addressColumns = getColumnsAndKeys(values: addressValues)
        let addressStatement = "INSERT INTO \(CustomizeRequest.databaseTableName)\(TableNames.CustomizeRequest.address) (\(addressColumns.names)) VALUES (\(addressColumns.keys))"
        try db.execute(sql: addressStatement, arguments: StatementArguments(addressValues))

        try customizeRequestServices?.forEach {
            try db.execute(sql: """
                                INSERT INTO \(CustomizeRequestService.databaseTableName)
                                (\(CommonColumns.fkId.rawValue),
                                \(CustomizeRequest.CustomizeRequestService.Columns.serviceId.rawValue), \(CustomizeRequest.CustomizeRequestService.Columns.title.rawValue),
                                \(CustomizeRequest.CustomizeRequestService.Columns.price.rawValue), \(CustomizeRequest.CustomizeRequestService.Columns.quantity.rawValue),
                                \(CustomizeRequest.CustomizeRequestService.Columns.updatedAt.rawValue))
                                VALUES (?, ?, ?, ?, ?, ?)
                                """, arguments: [id, $0.serviceId, $0.title,
                                                 "\($0.price)", $0.quantity,
                                                 $0.updatedAt.timeIntervalSince1970])
        }
    }
}




