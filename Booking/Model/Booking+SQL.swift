//
//  Booking+SQL.swift
//  Booking
//
//  Created by Fandy Gotama on 30/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform
import class Category.Category

extension Booking: MultiTableRecord {
    public typealias R = BookingListRequest
    
    public var contentValues: [String : DatabaseValueConvertible?] {
        
        var params: [String : DatabaseValueConvertible?] = [
            Booking.Columns.id.rawValue: id,
            Booking.Columns.eventName.rawValue: eventName,
            Booking.BookingStatus.Columns.id.rawValue: status.id.rawValue,
            Booking.BookingStatus.Columns.title.rawValue: status.title,
            Booking.BookingStatus.Columns.description.rawValue: status.description,
            Booking.BookingStatus.Columns.status.rawValue: status.status,
            Booking.Columns.bookingNumber.rawValue: bookingNumber,
            Booking.Columns.eventDate.rawValue: eventDate.timeIntervalSince1970,
            Booking.Columns.platformFee.rawValue: platformFee,
            Booking.Columns.discount.rawValue: discount,
            Booking.Columns.paymentURL.rawValue: paymentURL,
            Booking.Columns.totalDiscount.rawValue: totalDiscount,
            Booking.Columns.grandTotal.rawValue: grandTotal,
            CommonColumns.timestamp.rawValue: timeStamp
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
        try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.customer) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.venue) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
        try services.forEach({ item in
            try db.execute(sql: "DELETE FROM \(tableName)\(TableNames.Booking.Relation.bookingService) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [item.id])
        })
                
        try updateRelations(db, tableName: tableName)
    }
    
    public static func fetchAll(_ db: Database, request: BookingListRequest?, tableName: String) throws -> [Booking] {
        let query = getQueryStatement(request: request, tableName: tableName)
        
        let rows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName) \(query)")
        
        return try rows.map { row in
            let id = row[Booking.Columns.id]
    
            let artisan: Artisan?
            
            if let artisanRow = try Row.fetchOne(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.artisan) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id]) {
                
                let decoder = JSONDecoder()
                
                let metadata = try? decoder.decode([Artisan.Metadata].self, from: artisanRow[Artisan.Columns.metadata])
                let category = try? decoder.decode([Artisan.Category].self, from: artisanRow[Artisan.Columns.category])
                let avatar = try? decoder.decode(Media.self, from: artisanRow[Artisan.Columns.avatar])

                
                artisan = Artisan(id: artisanRow[Artisan.Columns.id],
                                      email: artisanRow[Artisan.Columns.email],
                                      name: artisanRow[Artisan.Columns.name],
                                      phoneNumber: artisanRow[Artisan.Columns.phoneNumber],
                                      username: artisanRow[Artisan.Columns.username],
                                      facebookID: artisanRow[Artisan.Columns.facebookID],
                                      googleID: artisanRow[Artisan.Columns.googleID],
                                      appleID: artisanRow[Artisan.Columns.appleID],
                                      type: .artisan,
                                      metadata: metadata,
                                      favorite: artisanRow[Artisan.Columns.favorite],
                                      jobDone: artisanRow[Artisan.Columns.jobDone],
                                      rating: artisanRow[Artisan.Columns.rating],
                                      category: category,
                                      avatar: avatar,
                                      isVerified: artisanRow[Artisan.Columns.isVerified],
                                      status: artisanRow[Artisan.Columns.status],
                                      hasAddress: false,
                                      categories: nil,
                                      instagram: nil,
                                      birthdate: nil,
                                      idCard: nil,
                                      bio: nil,
                                  timeStamp: Date().timeIntervalSince1970,
                                  createdAt: artisanRow[Artisan.Columns.created_at])
                
            } else {
                artisan = nil
            }
            
            let customer: NewProfile?

            
            if let customerRow = try Row.fetchOne(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.customer) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id]) {
                
                let decoder = JSONDecoder()
                
                let metadata = try? decoder.decode([NewProfile.Metadata].self, from: customerRow[NewProfile.Columns.metadata])
                let avatar = try? decoder.decode(Media.self, from: customerRow[NewProfile.Columns.avatar])

                
                customer = NewProfile(id: customerRow[NewProfile.Columns.id],
                                      email: customerRow[NewProfile.Columns.email],
                                      name: customerRow[NewProfile.Columns.name],
                                      phoneNumber: customerRow[NewProfile.Columns.phoneNumber],
                                      username: nil,
                                      facebookID: customerRow[NewProfile.Columns.facebookID],
                                      googleID: customerRow[NewProfile.Columns.googleID],
                                      appleID: customerRow[NewProfile.Columns.appleID],
                                      type: .customer,
                                      metadata: metadata,
                                      favorite: nil,
                                      jobDone: nil,
                                      rating: nil,
                                      category: nil,
                                      avatar: avatar,
                                      isVerified: customerRow[NewProfile.Columns.isVerified],
                                      status: customerRow[NewProfile.Columns.status],
                                      hasAddress: false,
                                      categories: nil,
                                      instagram: nil,
                                      birthdate: nil,
                                      idCard: nil,
                                      bio: nil,
                                      created_at: customerRow[NewProfile.Columns.created_at])
                
            } else {
                customer = nil
            }
            
            let addressRow = try Row.fetchOne(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.venue) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
            
            let address = Venue(id: addressRow?[Address.Columns.id],
                                venueName: addressRow?[Address.Columns.name],
                                latitude: addressRow?[Address.Columns.latitude] ?? 0.0,
                                longitude: addressRow?[Address.Columns.longitude] ?? 0.0,
                                notes: addressRow?[Address.Columns.notes],
                                address: addressRow?[Address.Columns.address])
                        
            let serviceRows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.bookingService) WHERE \(CommonColumns.fkId.rawValue) = ?", arguments: [id])
                        
            let services: [Booking.Service] = try serviceRows.map({ row -> Service in
                let categoryID: Int = row[Booking.Service.Columns.categoryId]
                
                let request = Category.filter(key: categoryID)
                let category = try Category.fetchOne(db, request) // String?
                
                return Service(id: row[Booking.Service.Columns.id],
                        title: row[Booking.Service.Columns.title],
                        notes: row[Booking.Service.Columns.notes],
                        quantity: row[Booking.Service.Columns.quantity],
                        price: row[Booking.Service.Columns.price],
                        discount: row[Booking.Service.Columns.discount],
                        category: category)
            })
            
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
            
//            let paging = Paging(currentPage: row[Paging.Columns.currentPage] ?? 1,
//                                limitPerPage: row[Paging.Columns.limitPerPage] ?? PlatformConfig.defaultLimit,
//                                totalPage: row[Paging.Columns.totalPage] ?? 1)
            
            let decodeDate: String = row[Booking.Columns.eventDate]
            
            let bookingStatus = BookingStatus(id: row[Booking.BookingStatus.Columns.id],
                                              title: row[Booking.BookingStatus.Columns.title],
                                              description: row[Booking.BookingStatus.Columns.description],
                                              status: row[Booking.BookingStatus.Columns.status])
            
            let historyRows = try Row.fetchAll(db, sql: "SELECT * FROM \(tableName)\(TableNames.Booking.Relation.statusHistory) WHERE \(CommonColumns.fkId.rawValue) = ? ORDER BY createdAt", arguments: [id])
            
            let histories: [Booking.StatusHistory] = historyRows.map({ row -> StatusHistory in
                let status = BookingStatus(id: row[Booking.BookingStatus.Columns.id],
                                           title: row[Booking.BookingStatus.Columns.title],
                                           description: row[Booking.BookingStatus.Columns.description],
                                           status: row[Booking.BookingStatus.Columns.status])
                return StatusHistory(id: row[Booking.StatusHistory.Columns.id],
                                     status: status,
                                     notes: row[Booking.StatusHistory.Columns.notes],
                                     createdAt: row[Booking.StatusHistory.Columns.createdAt],
                                     updatedAt: row[Booking.StatusHistory.Columns.updatedAt])
            })
            
            return Booking(id: row[Booking.Columns.id],
                           name: row[Booking.Columns.name],
                           eventName: row[Booking.Columns.eventName],
                           status: bookingStatus,
                           bookingNumber: row[Booking.Columns.bookingNumber],
                           services: services,
                           venue: address,
                           histories: histories,
                           eventDate: Date(timeIntervalSince1970: Double(decodeDate) ?? 0.0),
                           artisan: artisan,
                           customer: customer,
                           platformFee: Decimal(string: row[Booking.Columns.platformFee]) ?? 0,
                           discount: row[Booking.Columns.discount],
                           paymentURL: row[Booking.Columns.paymentURL],
                           totalDiscount: row[Booking.Columns.totalDiscount],
                           grantTotal: Decimal(string: row[Booking.Columns.grandTotal]) ?? 0,
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
        
       
        
        var addressValues: [String : DatabaseValueConvertible?] {
            return [
                CommonColumns.fkId.rawValue: id,
                Address.Columns.id.rawValue: venue.id,
                Address.Columns.name.rawValue: venue.venueName,
                Address.Columns.notes.rawValue: venue.notes,
                Address.Columns.address.rawValue: venue.address,
                Address.Columns.latitude.rawValue: venue.latitude,
                Address.Columns.longitude.rawValue: venue.longitude
            ]
        }
        
        let addressColumns = getColumnsAndKeys(values: addressValues)
        let addressStatement = "INSERT INTO \(tableName)\(TableNames.Booking.Relation.venue) (\(addressColumns.names)) VALUES (\(addressColumns.keys))"
        try db.execute(sql: addressStatement, arguments: StatementArguments(addressValues))
        
        if let artisan = artisan {
            var artisanValues: [String : DatabaseValueConvertible?] {
                return [
                    CommonColumns.fkId.rawValue: id,
                    Artisan.Columns.id.rawValue: artisan.id,
                    Artisan.Columns.email.rawValue: artisan.email,
                    Artisan.Columns.name.rawValue: artisan.name,
                    Artisan.Columns.phoneNumber.rawValue: artisan.phoneNumber,
                    Artisan.Columns.username.rawValue: artisan.username,
                    Artisan.Columns.facebookID.rawValue: artisan.facebookID,
                    Artisan.Columns.googleID.rawValue: artisan.googleID,
                    Artisan.Columns.appleID.rawValue: artisan.appleID,
                    Artisan.Columns.metadata.rawValue: artisan.metadataData,
                    Artisan.Columns.favorite.rawValue: artisan.favorite,
                    Artisan.Columns.jobDone.rawValue: artisan.jobDone,
                    Artisan.Columns.rating.rawValue: artisan.rating,
                    Artisan.Columns.category.rawValue: artisan.categoryData,
                    Artisan.Columns.avatar.rawValue: artisan.avatarData,
                    Artisan.Columns.status.rawValue: artisan.status
                ]
            }
            
            let artisanColumns = getColumnsAndKeys(values: artisanValues)
            
            let artisanStatement = "INSERT INTO \(tableName)\(TableNames.Booking.Relation.artisan) (\(artisanColumns.names)) VALUES (\(artisanColumns.keys))"
            try db.execute(sql: artisanStatement, arguments: StatementArguments(artisanValues))
        }
        
        if let customer = customer {
            var customerValues: [String : DatabaseValueConvertible?] {
                return [
                    CommonColumns.fkId.rawValue: id,
                    NewProfile.Columns.id.rawValue: customer.id,
                    NewProfile.Columns.email.rawValue: customer.email,
                    NewProfile.Columns.name.rawValue: customer.name,
                    NewProfile.Columns.phoneNumber.rawValue: customer.phoneNumber,
                    NewProfile.Columns.facebookID.rawValue: customer.facebookID,
                    NewProfile.Columns.googleID.rawValue: customer.googleID,
                    NewProfile.Columns.appleID.rawValue: customer.appleID,
                    NewProfile.Columns.metadata.rawValue: customer.metadataData,
                    NewProfile.Columns.avatar.rawValue: customer.avatarData,
                    NewProfile.Columns.status.rawValue: customer.status
                ]
            }
            
            let customerColumns = getColumnsAndKeys(values: customerValues)
            
            let customerStatement = "INSERT INTO \(tableName)\(TableNames.Booking.Relation.customer) (\(customerColumns.names)) VALUES (\(customerColumns.keys))"
            try db.execute(sql: customerStatement, arguments: StatementArguments(customerValues))
        }
        
        try services.forEach { service in
            var serviceValues: [String : DatabaseValueConvertible?] {
                return [
                    CommonColumns.fkId.rawValue: id,
                    Booking.Service.Columns.id.rawValue: service.id,
                    Booking.Service.Columns.title.rawValue: service.title,
                    Booking.Service.Columns.notes.rawValue: service.notes,
                    Booking.Service.Columns.quantity.rawValue: service.quantity,
                    Booking.Service.Columns.price.rawValue: service.price,
                    Booking.Service.Columns.discount.rawValue: service.discount,
                ]
            }
            
            let serviceColumns = getColumnsAndKeys(values: serviceValues)
            let serviceStatement = "INSERT INTO \(tableName)\(TableNames.Booking.Relation.venue) (\(serviceColumns.names)) VALUES (\(serviceValues.keys))"
            try db.execute(sql: serviceStatement, arguments: StatementArguments(serviceValues))
        }
        
        try histories.forEach { history in
            var historyValues: [String : DatabaseValueConvertible?] {
                return [
                    CommonColumns.fkId.rawValue: id,
                    Booking.StatusHistory.Columns.id.rawValue: history.id,
                    Booking.StatusHistory.Columns.notes.rawValue: history.notes,
                    Booking.BookingStatus.Columns.id.rawValue: history.status.id.rawValue,
                    Booking.BookingStatus.Columns.title.rawValue: history.status.title,
                    Booking.BookingStatus.Columns.description.rawValue: history.status.description,
                    Booking.BookingStatus.Columns.status.rawValue: history.status.status
                ]
            }
            
            let historyColumns = getColumnsAndKeys(values: historyValues)
            let historyStatement = "INSERT INTO \(tableName)\(TableNames.Booking.Relation.venue) (\(historyColumns.names)) VALUES (\(historyValues.keys))"
            try db.execute(sql: historyStatement, arguments: StatementArguments(historyValues))
        }
        
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


