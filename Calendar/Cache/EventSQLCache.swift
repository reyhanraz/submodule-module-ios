//
//  EventSQLCache.swift
//  Calendar
//
//  Created by Fandy Gotama on 21/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class EventSQLCache: SQLCache<CalendarRequest, Calendar.Event> {
    private static let _monthYearDatabaseTableName = "calendarMonthYear"
    
    public init(dbQueue: DatabaseQueue) {
        super.init(dbQueue: dbQueue, expiredAfter: 0)
    }
    
    public static func createTable(db: Database) throws {
        try db.create(table: _monthYearDatabaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column("month", .integer).notNull()
            body.column("year", .integer).notNull()
            body.column(CommonColumns.timestamp.rawValue, .integer).notNull()
        }
        
        try db.create(table: Calendar.Event.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .integer).references(_monthYearDatabaseTableName, column: CommonColumns._id.rawValue, onDelete: .cascade)
            body.column(Calendar.Event.Columns.id.rawValue, .text)
            body.column(Calendar.Event.Columns.status.rawValue, .text).notNull()
            body.column(Calendar.Event.Columns.htmlLink.rawValue, .text)
            body.column(Calendar.Event.Columns.created.rawValue, .integer).notNull()
            body.column(Calendar.Event.Columns.updated.rawValue, .integer).notNull()
            body.column(Calendar.Event.Columns.summary.rawValue, .text).notNull()
            body.column(Calendar.Event.Columns.description.rawValue, .text)
            body.column(Calendar.Event.Columns.location.rawValue, .text)
            body.column(Calendar.Event.Columns.creator.rawValue, .text).notNull()
            body.column(Calendar.Event.Columns.organizer.rawValue, .text).notNull()
            body.column(Calendar.Event.Columns.start.rawValue, .integer).notNull()
            body.column(Calendar.Event.Columns.end.rawValue, .integer).notNull()
            body.column(Calendar.Event.Columns.hangoutLink.rawValue, .text)
            body.column(Calendar.Event.Columns.isAllDay.rawValue, .boolean).notNull()
        }
        
        try db.create(table: Calendar.Event.User.databaseTableName) { body in
            body.column(CommonColumns._id.rawValue, .integer).primaryKey()
            body.column(CommonColumns.fkId.rawValue, .text).references(Calendar.Event.databaseTableName, column: CommonColumns._id.rawValue, onDelete: .cascade)
            body.column(Calendar.Event.User.Columns.email.rawValue, .text).notNull()
            body.column(Calendar.Event.User.Columns.isSelf.rawValue, .boolean)
            body.column(Calendar.Event.User.Columns.responseStatus.rawValue, .text)
        }
    }
    
    public override func getList(request: CalendarRequest? = nil) -> [Calendar.Event] {
        guard
            let request = request,
            let start = request.start
            else { return [] }
        
        let calendar = Foundation.Calendar.current
        
        let dateCalendar = calendar.dateComponents([.year, .month], from: start)
        
        guard let year = dateCalendar.year, let month = dateCalendar.month else { return [] }
        
        do {
            return try dbQueue.read({ db -> [Calendar.Event] in
                let eventRows = try Row.fetchAll(db, sql:
                    """
                    SELECT \(Calendar.Event.databaseTableName).* FROM \(Calendar.Event.databaseTableName)
                    INNER JOIN \(EventSQLCache._monthYearDatabaseTableName) ON \(Calendar.Event.databaseTableName).\(CommonColumns.fkId.rawValue) = \(EventSQLCache._monthYearDatabaseTableName).\(CommonColumns._id.rawValue)
                    WHERE month = ? AND year = ?
                    """, arguments: [month, year])
                
                return try eventRows.map { row in
                    let id = row[Calendar.Event.Columns.id]
                    
                    let userRows = try Row.fetchAll(db, sql: "SELECT * FROM \(Calendar.Event.User.databaseTableName) WHERE \(CommonColumns.fkId.rawValue) = ? ORDER BY _id ASC", arguments: [id])
                    
                    let users = userRows.map { userRow in
                        Calendar.Event.User(
                            email: userRow[Calendar.Event.User.Columns.email],
                            isSelf: userRow[Calendar.Event.User.Columns.isSelf],
                            responseStatus: userRow[Calendar.Event.User.Columns.responseStatus])
                    }
                    
                    return Calendar.Event(
                        id: row[Calendar.Event.Columns.id],
                        status: row[Calendar.Event.Columns.status],
                        htmlLink: row[Calendar.Event.Columns.htmlLink],
                        created: Date(timeIntervalSince1970: row[Calendar.Event.Columns.created]),
                        updated: Date(timeIntervalSince1970: row[Calendar.Event.Columns.updated]),
                        summary: row[Calendar.Event.Columns.summary],
                        description: row[Calendar.Event.Columns.description],
                        location: row[Calendar.Event.Columns.location],
                        creator: Calendar.Event.User(email: row[Calendar.Event.Columns.creator], isSelf: nil, responseStatus: nil),
                        organizer: Calendar.Event.User(email: row[Calendar.Event.Columns.organizer], isSelf: nil, responseStatus: nil),
                        start: Calendar.Event.Time(dateTime: row[Calendar.Event.Columns.start]),
                        end: Calendar.Event.Time(dateTime: row[Calendar.Event.Columns.end]),
                        attendees: users,
                        hangoutLink: row[Calendar.Event.Columns.hangoutLink],
                        isAllDay: row[Calendar.Event.Columns.isAllDay])
                }
            })
            
            
        } catch {
            assertionFailure()
        }
        
        return []
    }
    
    public override func put(model: Calendar.Event) {
        putList(models: [model])
    }
    
    public func putList(request: CalendarRequest, models: [Calendar.Event]) {
        guard let firstEventInMonth = request.start else { return }
        
        do {
            try dbQueue.inTransaction { db in
                
                // Insert month and year
                if try !insertMonthYear(db: db, date: firstEventInMonth) {
                    return .rollback
                }
                
                let fkId = db.lastInsertedRowID
                
                for record in models {
                    try db.execute(sql: """
                        INSERT OR REPLACE INTO \(Calendar.Event.databaseTableName)
                        (\(Calendar.Event.Columns.id.rawValue), \(CommonColumns.fkId.rawValue), \(Calendar.Event.Columns.status.rawValue),
                        \(Calendar.Event.Columns.htmlLink.rawValue), \(Calendar.Event.Columns.created.rawValue),
                        \(Calendar.Event.Columns.updated.rawValue), \(Calendar.Event.Columns.summary.rawValue),
                        \(Calendar.Event.Columns.description.rawValue), \(Calendar.Event.Columns.location.rawValue),
                        \(Calendar.Event.Columns.creator.rawValue), \(Calendar.Event.Columns.organizer.rawValue),
                        \(Calendar.Event.Columns.start.rawValue), \(Calendar.Event.Columns.end.rawValue),
                        \(Calendar.Event.Columns.hangoutLink.rawValue), \(Calendar.Event.Columns.isAllDay.rawValue))
                        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                        """, arguments:
                        [record.id, fkId, record.status,
                         record.htmlLink, record.created.timeIntervalSince1970,
                         record.updated.timeIntervalSince1970, record.summary,
                         record.description, record.location,
                         record.creator.email, record.organizer.email,
                         record.start.date.timeIntervalSince1970, record.end.date.timeIntervalSince1970,
                         record.hangoutLink, record.isAllDay]
                    )
                    
                    let eventFkId = db.lastInsertedRowID
                    
                    for user in record.attendees ?? [] {
                        try db.execute(sql: """
                            INSERT OR REPLACE INTO \(Calendar.Event.User.databaseTableName)
                            (
                            \(CommonColumns.fkId.rawValue),
                            \(Calendar.Event.User.Columns.email.rawValue),
                            \(Calendar.Event.User.Columns.isSelf.rawValue),
                            \(Calendar.Event.User.Columns.responseStatus.rawValue))
                            VALUES (?, ?, ?, ?)
                            """, arguments: [eventFkId, user.email, user.isSelf, user.responseStatus])
                    }
                }
                
                return .commit
            }
        } catch {
            assertionFailure()
        }
    }
    
    public override func getFilterQueries(request: R?) -> String? {
        return nil
    }
    
    public override func isCached(request: CalendarRequest?) -> Bool {
        guard let request = request, let start = request.start else { return false }
        
        let calendar = Foundation.Calendar.current
        
        let dateCalendar = calendar.dateComponents([.year, .month], from: start)
        
        guard let year = dateCalendar.year, let month = dateCalendar.month else { return false }
        
        do {
            let total = try dbQueue.read { db -> Int in
                return try Int.fetchOne(db, sql: """
                    SELECT COUNT(\(CommonColumns._id.rawValue)) FROM \(EventSQLCache._monthYearDatabaseTableName)
                    WHERE year = ? AND month = ?
                    """, arguments: [year, month]) ?? 0
            }
            
            return total > 0
        } catch {
            return false
        }
    }
    
    public override func isExpired(request: CalendarRequest?) -> Bool {
        guard let request = request, let start = request.start else { return false }
        
        let calendar = Foundation.Calendar.current
        
        let dateCalendar = calendar.dateComponents([.year, .month], from: start)
        
        guard let year = dateCalendar.year, let month = dateCalendar.month else { return false }
        
        let today = Date().timeIntervalSince1970
        
        do {
            let total = try dbQueue.read { db -> Int in
                return try Int.fetchOne(db, sql: """
                    SELECT COUNT(\(CommonColumns._id.rawValue)) FROM \(EventSQLCache._monthYearDatabaseTableName)
                    WHERE year = ? AND month = ? AND \(CommonColumns.timestamp.rawValue) < ?
                    """, arguments: [year, month, today]) ?? 0
            }
            
            return total > 0
        } catch {
            return true
        }
    }
    
    public override func remove(request: CalendarRequest) {
        guard let start = request.start else { return }
        
        let calendar = Foundation.Calendar.current
        
        let dateCalendar = calendar.dateComponents([.year, .month], from: start)
        
        guard let year = dateCalendar.year, let month = dateCalendar.month else { return }
        
        do {
            try dbQueue.write { db in
                try db.execute(
                    sql: "DELETE FROM \(EventSQLCache._monthYearDatabaseTableName) WHERE month = ? and year = ?",
                    arguments: [month, year])
            }
        } catch {
            
        }
    }
    
    public func insertMonthYear(request: CalendarRequest) {
        guard let start = request.start else { return }
        
        do {
            let _ = try dbQueue.write { db in
                try insertMonthYear(db: db, date: start)
            }
        } catch {
             assertionFailure()
        }
    }

    private func insertMonthYear(db: Database, date: Date) throws -> Bool {
        let today = Date()
        let calendar = Foundation.Calendar.current
        
        let dateCalendar = calendar.dateComponents([.year, .month], from: date)
        let todayCalendar = calendar.dateComponents([.year, .month], from: today)
        
        guard
            let year = dateCalendar.year,
            let month = dateCalendar.month,
            let todayYear = todayCalendar.year,
            let todayMonth = todayCalendar.month
            else { return false }
        
        let expireDate: Date
        
        // If current date month & year is less than today's, set default expired to 1 year, else 5 minutes
        if year < todayYear || (year == todayYear && month < todayMonth) {
            expireDate = calendar.date(byAdding: .year, value: 1, to: today)!
        } else {
            expireDate = calendar.date(byAdding: .minute, value: 5, to: today)!
        }
        
        // Insert month and year
        try db.execute(sql: """
            INSERT OR REPLACE INTO \(EventSQLCache._monthYearDatabaseTableName)
            (month, year, \(CommonColumns.timestamp.rawValue)) VALUES (?, ?, ?)
            """,
            arguments: [month, year, expireDate.timeIntervalSince1970])
        
        return true
    }
}



