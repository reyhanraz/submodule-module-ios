//
//  GroupedPaymentHistory.swift
//  Payment
//
//  Created by Fandy Gotama on 28/01/20.
//  Copyright © 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct GroupedPaymentHistory: Codable {
    public let date: Date
    public let histories: [PaymentHistory]
}

