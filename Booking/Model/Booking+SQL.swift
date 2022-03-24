//
//  Booking+SQL.swift
//  Booking
//
//  Created by Fandy Gotama on 30/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

extension Booking: MultiTableRecord {
    public typealias R = BookingListRequest
    
    public var contentValues: [String : DatabaseValueConvertible?] {
        
        var params: [String : DatabaseValueConvertible?] = [
            Booking.Columns.id.rawValue: id,
            Booking.Columns.status.rawValue: status.rawValue,
            Booking.Columns.eventName.rawValue: eventName,
            Booking.Columns.start.rawValue: start.timeIntervalSince1970,
            Booking.Columns.totalPrice.rawValue: "\(totalPrice)",
            Booking.Columns.notes.rawValue: notes,
            Booking.Columns.createdAt.rawValue: createdAt.timeIntervalSince1970,
            Booking.Columns.updatedAt.rawValue: updatedAt.timeIntervalSince1970,
            Booking.Columns.hasBid.rawValue: hasBid,
            Booking.Columns.isCustom.rawValue: isCustom,
            Booking.Columns.invoice.rawValue: invoice,
            Booking.Columns.paymentStatus.rawValue: paymentStatus.rawValue,
            CommonColumns.timestamp.rawValue: timestamp
        ]
        
        if let paging = paging {
            params[Paging.Columns.currentPage.rawValue] = paging.currentPage
            params[Paging.Columns.limitPerPage.rawValue] = paging.limitPerPage
            params[Paging.Columns.totalPage.rawValue] = paging.totalPage
        }
        
        return params
    }
    
    public func insert(_ db: Database, tableName: String) throws {
        let columns = columnNamesAndKeys
        
        let statement = "INSERT INTO \(tableName) (\(columns.names)) VALUES (\(columns.keys))"
        
        try db.execute(sql: statement, arguments: StatementArguments(contentValues))

        try updateRelations(db, tableName: tableName)
    }
    
    public func update(_ db: Database, tableName: String) throws {
        let columns = columnNamesForUpdate
        
        let statement = "UPDATE \(tableName) SET \(columns) WHERE \(Booking.Columns.id.rawValue) = :\(Booking.Columns.id.rawValue)"
        
        try db.execute(sql: statement, arguments: StatementArguments(contentValues))
        
        try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.customer) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.artisan) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.address) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.bookingService) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.customizeRequestService) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        
        try updateRelations(db, tableName: tableName)
    }
    
    public static func fetchAll(_ db: Database, request: BookingListRequest?, tableName: String) throws -> [Booking] {
        let query = getQueryStatement(request: request, tableName: tableName)
        
        let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName) \(query)")
        
        return try rows.map { row in
            let id = row[Booking.Columns.id]
            
            guard
                let customerRow = try Row.fetchOne(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.customer) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id]),
                let addressRow = try Row.fetchOne(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.address) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
                else { fatalError() }
            
            let customerAvatar: URL?
            let customerAvatarServingURL: URL?

            if let avatar = customerRow[User.Columns.avatarServingURL] as? String {
                customerAvatarServingURL = URL(string: avatar)
            } else {
                customerAvatarServingURL = nil
            }

            if let avatar = customerRow[User.Columns.avatar] as? String {
                customerAvatar = URL(string: avatar)
            } else {
                customerAvatar = nil
            }
            
            let artisan: Artisan?
            
            if let artisanRow = try Row.fetchOne(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.artisan) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id]) {
                let artisanAvatar: URL?
                let artisanAvatarServingURL: URL?

                if let avatar = artisanRow[Artisan.Columns.avatarServingURL] as? String {
                    artisanAvatarServingURL = URL(string: avatar)
                } else {
                    artisanAvatarServingURL = nil
                }

                if let avatar = artisanRow[Artisan.Columns.avatar] as? String {
                    artisanAvatar = URL(string: avatar)
                } else {
                    artisanAvatar = nil
                }
                
                let favorite: Artisan.Favorite?
                
                if let _ = artisanRow[Artisan.Favorite.Columns.count], let _ = artisanRow[Artisan.Favorite.Columns.isFavorite] {
                    favorite = Artisan.Favorite(count: artisanRow[Artisan.Favorite.Columns.count], isFavorite: artisanRow[Artisan.Favorite.Columns.isFavorite])
                } else {
                    favorite = nil
                }
                
                let booking: Artisan.Booking?
                
                if let _ = artisanRow[Artisan.Booking.Columns.count] {
                    booking = Artisan.Booking(count: artisanRow[Artisan.Booking.Columns.count])
                } else {
                    booking = nil
                }
                
                artisan = Artisan(
                    id: artisanRow[Artisan.Columns.id],
                    email: artisanRow[Artisan.Columns.email],
                    name: artisanRow[Artisan.Columns.name],
                    username: artisanRow[Artisan.Columns.username],
                    phone: artisanRow[Artisan.Columns.phone],
                    verified: nil,
                    avatar: artisanAvatar,
                    avatarServingURL: artisanAvatarServingURL,
                    gender: artisanRow[Artisan.Columns.gender],
                    dob: artisanRow[Artisan.Columns.dob],
                    reviewRating: artisanRow[Artisan.Columns.reviewRating],
                    status: artisanRow[Artisan.Columns.status],
                    createdAt: artisanRow[Artisan.Columns.createdAt],
                    updatedAt: artisanRow[Artisan.Columns.updatedAt],
                    emailConfirmed: artisanRow[Artisan.Columns.emailConfirmed],
                    instagram: artisanRow[Artisan.Columns.instagram],
                    about: artisanRow[Artisan.Columns.about],
                    level: artisanRow[Artisan.Columns.level],
                    services: nil,
                    categories: nil,
                    categoryTypes: nil,
                    favorite: favorite,
                    booking: booking,
                    distance: nil,
                    identityCardNumber: nil,
                    identityCardURL: nil,
                    identityCardServingURL: nil,
                    hasReview: artisanRow[Artisan.Columns.hasReview],
                    paging: nil)
            } else {
                artisan = nil
            }
            
            let customer = User(
                id: customerRow[User.Columns.id],
                email: customerRow[User.Columns.email],
                name: customerRow[User.Columns.name],
                phone: customerRow[User.Columns.phone],
                avatar: customerAvatar,
                avatarServingURL: customerAvatarServingURL,
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
                lat: addressRow[Address.Columns.lat],
                lon: addressRow[Address.Columns.lon],
                timestamp: nil,
                address: "",
                rawAddress: nil)
            
            let serviceRows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.bookingService) WHERE \(CommonColumns.fkId.rawValue) = ? ORDER BY _id ASC", arguments: [id])
            
            let serviceItems = serviceRows.map { serviceRow -> BookingService in
                return BookingService(
                    bookingId: row[Booking.Columns.id],
                    serviceId: serviceRow[BookingService.Columns.serviceId],
                    title: serviceRow[BookingService.Columns.title],
                    price: Decimal(string: serviceRow[BookingService.Columns.price]) ?? 0,
                    quantity: serviceRow[BookingService.Columns.quantity],
                    notes: serviceRow[BookingService.Columns.notes],
                    updatedAt: Date(timeIntervalSince1970: serviceRow[BookingService.Columns.updatedAt]))
            }
            
            let customizeRequestRows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.customizeRequestService) WHERE \(CommonColumns.fkId.rawValue) = ? ORDER BY _id ASC", arguments: [id])
            
            let customizeRequestItems = customizeRequestRows.map { serviceRow -> CustomizeRequestService in
                return CustomizeRequestService(
                    bookingId: row[Booking.Columns.id],
                    serviceId: serviceRow[CustomizeRequestService.Columns.serviceId],
                    title: serviceRow[CustomizeRequestService.Columns.title],
                    price: Decimal(string: serviceRow[CustomizeRequestService.Columns.price]) ?? 0,
                    quantity: serviceRow[CustomizeRequestService.Columns.quantity],
                    updatedAt: serviceRow[CustomizeRequestService.Columns.updatedAt])
                
            }
            
            let paging = Paging(currentPage: row[Paging.Columns.currentPage] ?? 1,
                                limitPerPage: row[Paging.Columns.limitPerPage] ?? PlatformConfig.defaultLimit,
                                totalPage: row[Paging.Columns.totalPage] ?? 1)
            
            return Booking(
                id: row[Booking.Columns.id],
                invoice: row[Booking.Columns.invoice],
                status: Booking.Status(rawValue: row[Booking.Columns.status]) ?? .booking,
                eventName: row[Booking.Columns.eventName],
                start: Date(timeIntervalSince1970: row[Booking.Columns.start]),
                totalPrice: Decimal(string: row[Booking.Columns.totalPrice]) ?? 0,
                createdAt: Date(timeIntervalSince1970: row[Booking.Columns.createdAt]),
                updatedAt: Date(timeIntervalSince1970: row[Booking.Columns.updatedAt]),
                artisan: artisan,
                customer: customer,
                bookingAddress: nil,
                notes: row[Booking.Columns.notes],
                bookingServices: serviceItems,
                customizeRequestServices: customizeRequestItems,
                paging: paging,
                hasBid: row[Booking.Columns.hasBid],
                isCustom: row[Booking.Columns.isCustom],
                paymentStatus: Booking.PaymentStatus(rawValue: row[Booking.Columns.paymentStatus]) ?? .unpaid,
                timestamp: row[CommonColumns.timestamp])
        }
    }
    
    public static func delete(_ db: Database, model: Booking, tableName: String) throws -> Bool {
        try db.execute(sql: "DELETE FROM \(tableName) WHERE \(Booking.Columns.id.rawValue) = ?", arguments: [model.id])
        
        return true
    }
    
    public static func getQueryStatement(request: BookingListRequest?, tableName: String) -> String {
        var query = "WHERE \(tableName).\(CommonColumns._id.rawValue) != -1"
        
        if let request = request {
            if request.page > 0 && !request.ignorePaging {
                query += " AND \(Paging.Columns.currentPage.rawValue) = \(request.page)"
            } else if let id = request.id {
                query += " AND \(Booking.Columns.id.rawValue) = \(id)"
            }
        }
        
        return query
    }
    
    private func updateRelations(_ db: Database, tableName: String) throws {
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
                User.Columns.avatarServingURL.rawValue: customer.avatar?.servingURL,
                User.Columns.emailConfirmed.rawValue: customer.emailConfirmed
            ]
        }
        
//        var addressValues: [String : DatabaseValueConvertible?] {
//            return [
//                CommonColumns.fkId.rawValue: id,
//                Address.Columns.id.rawValue: address?.id,
//                Address.Columns.userId.rawValue: address?.userId,
//                Address.Columns.provinceId.rawValue: address?.provinceId,
//                Address.Columns.districtId.rawValue: address?.districtId,
//                Address.Columns.areaId.rawValue: address?.areaId,
//                Address.Columns.name.rawValue: address?.name,
//                Address.Columns.detail.rawValue: address?.detail,
//                Address.Columns.provinceName.rawValue: address?.provinceName,
//                Address.Columns.districtName.rawValue: address?.districtName,
//                Address.Columns.districtType.rawValue: address?.districtType,
//                Address.Columns.subDistrictName.rawValue: address?.subDistrictName,
//                Address.Columns.urbanVillageName.rawValue: address?.urbanVillageName,
//                Address.Columns.postalCode.rawValue: address?.postalCode,
//                Address.Columns.lat.rawValue: address?.lat,
//                Address.Columns.lon.rawValue: address?.lon
//            ]
//        }
        
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
                    Artisan.Columns.avatarServingURL.rawValue: artisan.avatar?.servingURL,
                    Artisan.Columns.instagram.rawValue: artisan.instagram,
                    Artisan.Columns.distance.rawValue: artisan.distance,
                    Artisan.Favorite.Columns.count.rawValue: artisan.favorite?.count,
                    Artisan.Favorite.Columns.isFavorite.rawValue: artisan.favorite?.isFavorite,
                    Artisan.Booking.Columns.count.rawValue: artisan.booking?.count,
                    Artisan.Columns.reviewRating.rawValue: artisan.reviewRating,
                    Artisan.Columns.about.rawValue: artisan.about,
                    Artisan.Columns.emailConfirmed.rawValue: artisan.emailConfirmed,
                    Artisan.Columns.hasReview.rawValue: artisan.hasReview
                ]
            }
            
            let artisanColumns = getColumnsAndKeys(values: artisanValues)
            
            let artisanStatement = "INSERT INTO \(tableName)\(TableNames.Booking.Relation.artisan) (\(artisanColumns.names)) VALUES (\(artisanColumns.keys))"
            try db.execute(sql: artisanStatement, arguments: StatementArguments(artisanValues))
        }
        
        let customerColumns = getColumnsAndKeys(values: customerValues)
        let customerStatement = "INSERT INTO \(tableName)\(TableNames.Booking.Relation.customer) (\(customerColumns.names)) VALUES (\(customerColumns.keys))"
        try db.execute(sql: customerStatement, arguments: StatementArguments(customerValues))
        
//        let addressColumns = getColumnsAndKeys(values: addressValues)
//        let addressStatement = "INSERT INTO \(tableName)\(TableNames.Booking.Relation.address) (\(addressColumns.names)) VALUES (\(addressColumns.keys))"
//        try db.execute(sql: addressStatement, arguments: StatementArguments(addressValues))
        
        try bookingServices?.forEach {
            try db.execute(sql: """
                INSERT INTO \(tableName)\(TableNames.Booking.Relation.bookingService)
                (\(CommonColumns.fkId.rawValue),
                \(Booking.BookingService.Columns.serviceId.rawValue), \(Booking.BookingService.Columns.title.rawValue),
                \(Booking.BookingService.Columns.price.rawValue), \(Booking.BookingService.Columns.quantity.rawValue),
                \(Booking.BookingService.Columns.notes.rawValue), \(Booking.BookingService.Columns.updatedAt.rawValue))
                VALUES (?, ?, ?, ?, ?, ?, ?)
                """, arguments: [id, $0.serviceId, $0.title,
                                 "\($0.price)", $0.quantity, $0.notes,
                                 $0.updatedAt.timeIntervalSince1970])
        }
        
        try customizeRequestServices?.forEach {
            try db.execute(sql: """
                INSERT INTO \(tableName)\(TableNames.Booking.Relation.customizeRequestService)
                (\(CommonColumns.fkId.rawValue),
                \(Booking.CustomizeRequestService.Columns.serviceId.rawValue), \(Booking.CustomizeRequestService.Columns.title.rawValue),
                \(Booking.CustomizeRequestService.Columns.price.rawValue), \(Booking.CustomizeRequestService.Columns.quantity.rawValue),
                \(Booking.CustomizeRequestService.Columns.updatedAt.rawValue))
                VALUES (?, ?, ?, ?, ?, ?)
                """, arguments: [id, $0.serviceId, $0.title,
                                 "\($0.price)", $0.quantity,
                                 $0.updatedAt.timeIntervalSince1970])
        }
    }
}


