//
//  Calendar.swift
//  Calendar
//
//  Created by Fandy Gotama on 20/10/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform
import GRDB

public struct Calendar: Codable {
    public let authorized: Bool
    public let authURL: URL?
    public let events: [Event]?
    
    public init(authorized: Bool, authURL: URL?, events: [Event]?) {
        self.authorized = authorized
        self.authURL = authURL
        self.events = events
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        authorized = try container.decode(Bool.self, forKey: .authorized)
        
        authURL = try container.decodeIfPresent(URL.self, forKey: .authURL)
        events = try container.decodeIfPresent([Event].self, forKey: .events)
    }
    
    enum CodingKeys: String, CodingKey {
        case authorized
        case authURL = "authUrl"
        case events
    }
    
    public struct Event: Codable, FetchableRecord, PersistableRecord {
        public static var databaseTableName = "calendarEvent"
        
        public let id: String
        public let status: String
        public let htmlLink: URL?
        public let created: Date
        public let updated: Date
        public let summary: String
        public let description: String?
        public let location: String?
        public let creator: Event.User
        public let organizer: Event.User
        public let start: Event.Time
        public let end: Event.Time
        public let attendees: [Event.User]?
        public let hangoutLink: URL?
        public let isAllDay: Bool
        
        public struct User: Codable, FetchableRecord, PersistableRecord {
            public static var databaseTableName = "calendarEventUser"
            
            public let email: String
            public let isSelf: Bool?
            public let responseStatus: String?
            
            enum CodingKeys: String, CodingKey {
                case email
                case isSelf = "self"
                case responseStatus
            }
            
            enum Columns: String, ColumnExpression {
                case email
                case isSelf
                case responseStatus
            }
        }
        
        public struct Time: Codable {
            let dateTime: Date?
            let dateOnly: Date?
            
            public var date: Date {
                return dateTime == nil ? dateOnly! : dateTime!
            }
            
            public init(dateTime: Date?) {
                self.dateTime = dateTime
                self.dateOnly = dateTime
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                let decodedTime = try container.decodeIfPresent(String.self, forKey: .dateTime)
                let decodedDate = try container.decodeIfPresent(String.self, forKey: .dateOnly)
                              
                dateTime = decodedTime?.toDate(format: "yyyy-MM-dd'T'HH:mm:ssXXXXX")!
                dateOnly = decodedDate?.toDate(format: "yyyy-MM-dd")
            }
            
            enum CodingKeys: String, CodingKey {
                case dateTime
                case dateOnly = "date"
            }
        }
        
        public init(id: String,
                    status: String,
                    htmlLink: URL?,
                    created: Date,
                    updated: Date,
                    summary: String,
                    description: String?,
                    location: String?,
                    creator: Event.User,
                    organizer: Event.User,
                    start: Event.Time,
                    end: Event.Time,
                    attendees: [Event.User]?,
                    hangoutLink: URL?,
                    isAllDay: Bool) {
            
            self.id = id
            self.status = status
            self.htmlLink = htmlLink
            self.created = created
            self.updated = updated
            self.summary = summary
            self.description = description
            self.location = location
            self.creator = creator
            self.organizer = organizer
            self.start = start
            self.end = end
            self.attendees = attendees
            self.hangoutLink = hangoutLink
            self.isAllDay = isAllDay
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let decodedCreated = try container.decode(String.self, forKey: .created)
            let decodedUpdated = try container.decode(String.self, forKey: .updated)
            
            id = try container.decode(String.self, forKey: .id)
            status = try container.decode(String.self, forKey: .status)
            summary = try container.decode(String.self, forKey: .summary)
            creator = try container.decode(Event.User.self, forKey: .creator)
            organizer = try container.decode(Event.User.self, forKey: .organizer)
            start = try container.decode(Event.Time.self, forKey: .start)
            
            created = decodedCreated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
            updated = decodedUpdated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
            
            attendees = try container.decodeIfPresent([Event.User].self, forKey: .attendees)
            hangoutLink = try container.decodeIfPresent(URL.self, forKey: .hangoutLink)
            description = try container.decodeIfPresent(String.self, forKey: .description)
            location = try container.decodeIfPresent(String.self, forKey: .location)
            htmlLink = try container.decodeIfPresent(URL.self, forKey: .htmlLink)
            
            isAllDay = start.dateOnly != nil
            
            if isAllDay {
                end = start
            } else {
                end = try container.decode(Event.Time.self, forKey: .end)
            }
        }
        
        enum Columns: String, ColumnExpression {
            case id
            case status
            case htmlLink
            case created
            case updated
            case summary
            case description
            case location
            case creator
            case organizer
            case start
            case end
            case attendees
            case hangoutLink
            case isAllDay
        }
    }
}
