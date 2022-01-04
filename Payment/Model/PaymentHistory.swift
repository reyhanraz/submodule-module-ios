//
//  PaymentHistories.swift
//  Payment
//
//  Created by Fandy Gotama on 28/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import GRDB
import Platform

public class PaymentHistory: Codable, Pageable, FetchableRecord, PersistableRecord {
    public enum TransactionType: String, Codable {
        case debit
        case credit
    }
    
    public let id: Int
    public let context: String
    public let amount: Decimal
    public let status: String
    public let transactionType: TransactionType
    public let createdAt: Date
    public var timestamp: TimeInterval?
    public var paging: Paging?
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let decodedCreated = try container.decode(String.self, forKey: .createdAt)
       
        createdAt = decodedCreated.toDate(format: "yyyy-MM-dd'T'HH:mm:ss.SSSZ") ?? Date()
        
        id = try container.decode(Int.self, forKey: .id)
        context = try container.decode(String.self, forKey: .context)
        amount = try container.decode(Decimal.self, forKey: .amount)
        status = try container.decode(String.self, forKey: .status)
        transactionType = try container.decode(TransactionType.self, forKey: .transactionType)
    }
    
    public required init(row: Row) {
        id = row[CommonColumns.id]
        context = row[Columns.context]
        amount = Decimal(string: row[Columns.amount]) ?? 0
        status = row[Columns.status]
        transactionType = TransactionType(rawValue: row[Columns.transactionType]) ?? .debit
        createdAt = Date(timeIntervalSince1970: row[Columns.createdAt])
        paging = Paging(
            currentPage: row[Paging.Columns.currentPage],
            limitPerPage: row[Paging.Columns.limitPerPage],
            totalPage: row[Paging.Columns.totalPage])
    }
    
    public func encode(to container: inout PersistenceContainer) {
        container[CommonColumns.id] = id
        container[Columns.context] = context
        container[Columns.amount] = "\(amount)"
        container[Columns.status] = status
        container[Columns.transactionType] = transactionType.rawValue
        container[Columns.createdAt] = createdAt.timeIntervalSince1970
        container[Paging.Columns.currentPage] = paging?.currentPage ?? 1
        container[Paging.Columns.totalPage] = paging?.totalPage ?? 1
        container[Paging.Columns.limitPerPage] = paging?.limitPerPage ?? 1
        container[CommonColumns.timestamp] = timestamp
    }
        
    enum Columns: String, ColumnExpression {
        case id
        case context
        case amount
        case status
        case transactionType
        case createdAt
    }
}
