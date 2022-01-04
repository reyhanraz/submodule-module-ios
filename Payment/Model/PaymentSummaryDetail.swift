//
// Created by Fandy Gotama on 05/01/20.
// Copyright (c) 2020 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct PaymentSummaryDetail: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?

    public struct Data: Codable {
        public let paymentSummary: PaymentSummary
    }
}

