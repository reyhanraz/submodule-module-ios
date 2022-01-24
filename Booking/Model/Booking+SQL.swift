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
            Booking.Columns.eventName.rawValue: eventName,
            Booking.Columns.clientName.rawValue: clientName,
            Booking.Columns.status.rawValue: status,
            Booking.Columns.bookingNumber.rawValue: bookingNumber,
            Booking.Columns.eventDate.rawValue: eventDate.timeIntervalSince1970,
            Booking.Columns.platformFee.rawValue: "\(platformFee)",
            Booking.Columns.discount.rawValue: discount,
            Booking.Columns.paymentURL.rawValue: paymentURL,
            Booking.Columns.totalDiscount.rawValue: totalDiscount,
            Booking.Columns.grandTotal.rawValue: "\(grandTotal)"
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
        
        try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.artisan) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.address) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.bookingStatus) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.Invoice.invoice) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        try invoice.items.forEach({ item in
            try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.Invoice.items) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [invoice.id])
            try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.Invoice.service) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [item.id])
        })
                
        try updateRelations(db, tableName: tableName)
    }
    
    public static func fetchAll(_ db: Database, request: BookingListRequest?, tableName: String) throws -> [Booking] {
        let query = getQueryStatement(request: request, tableName: tableName)
        
        let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName) \(query)")
        
        return try rows.map { row in
            let id = row[Booking.Columns.id]
    
            let artisan: Booking.Artisan?
            
            if let artisanRow = try Row.fetchOne(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.artisan) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id]) {
                let artisanAvatar: URL?

                if let avatar = artisanRow[Artisan.Columns.avatar] as? String {
                    artisanAvatar = URL(string: avatar)
                } else {
                    artisanAvatar = nil
                }
                
                artisan = Artisan(id: artisanRow[Artisan.Columns.id],
                                  name: artisanRow[Artisan.Columns.name],
                                  avatar: artisanAvatar,
                                  ratings: artisanRow[Artisan.Columns.ratings])
            } else {
                artisan = nil
            }
            
            
            let bookingStatusRow = try Row.fetchOne(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.bookingStatus) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
            
            let bookingStatus = BookingStatus(id: bookingStatusRow?[Booking.BookingStatus.Columns.id] ?? -1,
                                              title: bookingStatusRow?[Booking.BookingStatus.Columns.title] ?? "",
                                              description: bookingStatusRow?[Booking.BookingStatus.Columns.description] ?? "")
            
            let addressRow = try Row.fetchOne(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.address) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
            
            let address = EventAddress(name: addressRow?[Address.Columns.name],
                                       latitude: addressRow?[Address.Columns.lat],
                                       longitude: addressRow?[Address.Columns.lon],
                                       addressNote: addressRow?[Address.Columns.detail],
                                       addressDetail: addressRow?[Address.Columns.address])
            
            let invoiceRow = try Row.fetchOne(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.Invoice.invoice) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
            
            let invoiceID = (invoiceRow?[Invoice.Columns.id] ?? "") as String
            
            let itemRow = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.Invoice.items) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [invoiceID])
            
            let items: [Item] = try itemRow.map { row -> Item in
                let itemID = row[Booking.Item.Columns.id] as Int
                
                let invoiceRow = try Row.fetchOne(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.Invoice.service) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [itemID])

                let services = Service(name: invoiceRow?[Booking.Service.Columns.name],
                               qty: invoiceRow?[Booking.Service.Columns.qty],
                                       price: Decimal(string: invoiceRow?[Booking.Service.Columns.price] ?? "0") ?? 0,
                               discount: invoiceRow?[Booking.Service.Columns.discount],
                                       total: Decimal(string: invoiceRow?[Booking.Service.Columns.total] ?? "0") ?? 0)
                
                return Item(id: itemID,
                            service: services,
                            notes: row[Booking.Item.Columns.notes])
            }
                        
            let invoice = Invoice(id: invoiceID,
                                  number: invoiceRow?[Booking.Invoice.Columns.number],
                                  items: items,
                                  subtotal: Decimal(string: invoiceRow?[Booking.Invoice.Columns.subtotal] ?? "") ?? 0)
            
            
            
            
//            let customer = User(
//                id: customerRow[User.Columns.id],
//                email: customerRow[User.Columns.email],
//                name: customerRow[User.Columns.name],
//                phone: customerRow[User.Columns.phone],
//                avatar: customerAvatar,
//                avatarServingURL: customerAvatarServingURL,
//                gender: customerRow[User.Columns.gender],
//                dob: customerRow[User.Columns.dob],
//                status: customerRow[User.Columns.status],
//                createdAt: customerRow[User.Columns.createdAt],
//                updatedAt: customerRow[User.Columns.updatedAt],
//                emailConfirmed: customerRow[User.Columns.emailConfirmed])
//
//            let serviceRows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.bookingService) WHERE \(CommonColumns.fkId.rawValue) = ? ORDER BY _id ASC", arguments: [id])
//
//            let serviceItems = serviceRows.map { serviceRow -> BookingService in
//                return BookingService(
//                    bookingId: row[Booking.Columns.id],
//                    serviceId: serviceRow[BookingService.Columns.serviceId],
//                    title: serviceRow[BookingService.Columns.title],
//                    price: Decimal(string: serviceRow[BookingService.Columns.price]) ?? 0,
//                    quantity: serviceRow[BookingService.Columns.quantity],
//                    notes: serviceRow[BookingService.Columns.notes],
//                    updatedAt: Date(timeIntervalSince1970: serviceRow[BookingService.Columns.updatedAt]))
//            }
//
//            let customizeRequestRows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.customizeRequestService) WHERE \(CommonColumns.fkId.rawValue) = ? ORDER BY _id ASC", arguments: [id])
//
//            let customizeRequestItems = customizeRequestRows.map { serviceRow -> CustomizeRequestService in
//                return CustomizeRequestService(
//                    bookingId: row[Booking.Columns.id],
//                    serviceId: serviceRow[CustomizeRequestService.Columns.serviceId],
//                    title: serviceRow[CustomizeRequestService.Columns.title],
//                    price: Decimal(string: serviceRow[CustomizeRequestService.Columns.price]) ?? 0,
//                    quantity: serviceRow[CustomizeRequestService.Columns.quantity],
//                    updatedAt: serviceRow[CustomizeRequestService.Columns.updatedAt])
//
//            }
            
            let paging = Paging(currentPage: row[Paging.Columns.currentPage] ?? 1,
                                limitPerPage: row[Paging.Columns.limitPerPage] ?? PlatformConfig.defaultLimit,
                                totalPage: row[Paging.Columns.totalPage] ?? 1)
            
            let decodeDate: String = row[Booking.Columns.eventDate]
            return Booking(id: row[Booking.Columns.id],
                           eventName: row[Booking.Columns.eventName],
                           clientName: row[Booking.Columns.clientName],
                           status: row[Booking.Columns.status],
                           bookingNumber: row[Booking.Columns.bookingNumber],
                           bookingStatus: bookingStatus,
                           eventAddress: address,
                           eventDate: Date(timeIntervalSince1970: Double(decodeDate) ?? 0.0),
                           artisan: artisan,
                           invoice: invoice,
                           platformFee: Decimal(string: row[Booking.Columns.platformFee]) ?? 0,
                           discount: row[Booking.Columns.discount],
                           paymentURL: row[Booking.Columns.paymentURL],
                           totalDiscount: row[Booking.Columns.totalDiscount],
                           grantTotal: Decimal(string: row[Booking.Columns.grandTotal]) ?? 0)
            
//            return Booking(
//                id: row[Booking.Columns.id],
//                invoice: row[Booking.Columns.invoice],
//                status: Booking.Status(rawValue: row[Booking.Columns.status]) ?? .booking,
//                eventName: row[Booking.Columns.eventName],
//                start: Date(timeIntervalSince1970: row[Booking.Columns.start]),
//                totalPrice: Decimal(string: row[Booking.Columns.totalPrice]) ?? 0,
//                createdAt: Date(timeIntervalSince1970: row[Booking.Columns.createdAt]),
//                updatedAt: Date(timeIntervalSince1970: row[Booking.Columns.updatedAt]),
//                artisan: artisan,
//                customer: customer,
//                bookingAddress: nil,
//                notes: row[Booking.Columns.notes],
//                bookingServices: serviceItems,
//                customizeRequestServices: customizeRequestItems,
//                paging: paging,
//                hasBid: row[Booking.Columns.hasBid],
//                isCustom: row[Booking.Columns.isCustom],
//                paymentStatus: Booking.PaymentStatus(rawValue: row[Booking.Columns.paymentStatus]) ?? .unpaid,
//                timestamp: row[CommonColumns.timestamp])
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
        
       
        
        var addressValues: [String : DatabaseValueConvertible?] {
            return [
                CommonColumns.fkId.rawValue: id,
                Address.Columns.name.rawValue: eventAddress?.name,
                Address.Columns.detail.rawValue: eventAddress?.addressNote,
                Address.Columns.address.rawValue: eventAddress?.addressDetail,
                Address.Columns.lat.rawValue: eventAddress?.latitude,
                Address.Columns.lon.rawValue: eventAddress?.longitude
            ]
        }
        
        if let artisan = artisan {
            var artisanValues: [String : DatabaseValueConvertible?] {
                return [
                    CommonColumns.fkId.rawValue: id,
                    Artisan.Columns.id.rawValue: artisan.id,
                    Artisan.Columns.name.rawValue: artisan.name,
                    Artisan.Columns.avatar.rawValue: artisan.avatar,
                    Artisan.Columns.ratings.rawValue: artisan.ratings
                ]
            }
            
            let artisanColumns = getColumnsAndKeys(values: artisanValues)
            
            let artisanStatement = "INSERT INTO \(tableName)\(TableNames.Booking.Relation.artisan) (\(artisanColumns.names)) VALUES (\(artisanColumns.keys))"
            try db.execute(sql: artisanStatement, arguments: StatementArguments(artisanValues))
        }
        
        let addressColumns = getColumnsAndKeys(values: addressValues)
        let addressStatement = "INSERT INTO \(tableName)\(TableNames.Booking.Relation.address) (\(addressColumns.names)) VALUES (\(addressColumns.keys))"
        try db.execute(sql: addressStatement, arguments: StatementArguments(addressValues))
        
        try db.execute(sql: """
            INSERT INTO \(tableName)\(TableNames.Booking.Relation.bookingStatus)
            (\(CommonColumns.fkId.rawValue),
            \(Booking.BookingStatus.Columns.id.rawValue), \(Booking.BookingStatus.Columns.title.rawValue),
            \(Booking.BookingStatus.Columns.description.rawValue))
            VALUES (?, ?, ?, ?)
            """, arguments: [id, bookingStatus?.id.rawValue, bookingStatus?.title, bookingStatus?.description])
        
        try db.execute(sql: """
            INSERT INTO \(tableName)\(TableNames.Booking.Relation.Invoice.invoice)
            (\(CommonColumns.fkId.rawValue),
            \(Booking.Invoice.Columns.id.rawValue), \(Booking.Invoice.Columns.number.rawValue),
            \(Booking.Invoice.Columns.subtotal.rawValue))
            VALUES (?, ?, ?, ?)
            """, arguments: [id, invoice.id, invoice.number, "\(invoice.subtotal ?? 0)"])
        
        try invoice.items.forEach({ item in
            try db.execute(sql: """
            INSERT INTO \(tableName)\(TableNames.Booking.Relation.Invoice.items)
            (\(CommonColumns.fkId.rawValue),
            \(Booking.Item.Columns.id.rawValue), \(Booking.Item.Columns.notes.rawValue))
            VALUES (?, ?, ?)
            """, arguments: [invoice.id, item.id, item.notes])
            
            try db.execute(sql: """
            INSERT INTO \(tableName)\(TableNames.Booking.Relation.Invoice.service)
            (\(CommonColumns.fkId.rawValue),
            \(Booking.Service.Columns.name.rawValue),
            \(Booking.Service.Columns.qty.rawValue),
            \(Booking.Service.Columns.price.rawValue),
            \(Booking.Service.Columns.discount.rawValue),
            \(Booking.Service.Columns.total.rawValue))
            VALUES (?, ?, ?, ?, ?, ?)
            """, arguments: [item.id, item.service?.name, item.service?.qty, "\(item.service?.price ?? 0)", item.service?.discount, "\(item.service?.total ?? 0)"])
        })
        
//
//        try bookingServices?.forEach {
//            try db.execute(sql: """
//                INSERT INTO \(tableName)\(TableNames.Booking.Relation.bookingService)
//                (\(CommonColumns.fkId.rawValue),
//                \(Booking.BookingService.Columns.serviceId.rawValue), \(Booking.BookingService.Columns.title.rawValue),
//                \(Booking.BookingService.Columns.price.rawValue), \(Booking.BookingService.Columns.quantity.rawValue),
//                \(Booking.BookingService.Columns.notes.rawValue), \(Booking.BookingService.Columns.updatedAt.rawValue))
//                VALUES (?, ?, ?, ?, ?, ?, ?)
//                """, arguments: [id, $0.serviceId, $0.title,
//                                 "\($0.price)", $0.quantity, $0.notes,
//                                 $0.updatedAt.timeIntervalSince1970])
//        }
//
//        try customizeRequestServices?.forEach {
//            try db.execute(sql: """
//                INSERT INTO \(tableName)\(TableNames.Booking.Relation.customizeRequestService)
//                (\(CommonColumns.fkId.rawValue),
//                \(Booking.CustomizeRequestService.Columns.serviceId.rawValue), \(Booking.CustomizeRequestService.Columns.title.rawValue),
//                \(Booking.CustomizeRequestService.Columns.price.rawValue), \(Booking.CustomizeRequestService.Columns.quantity.rawValue),
//                \(Booking.CustomizeRequestService.Columns.updatedAt.rawValue))
//                VALUES (?, ?, ?, ?, ?, ?)
//                """, arguments: [id, $0.serviceId, $0.title,
//                                 "\($0.price)", $0.quantity,
//                                 $0.updatedAt.timeIntervalSince1970])
//        }
    }
}


