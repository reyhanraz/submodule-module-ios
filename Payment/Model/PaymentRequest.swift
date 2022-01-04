//
// Created by Fandy Gotama on 05/01/20.
// Copyright (c) 2020 Adrena Teknologi Indonesia. All rights reserved.
//

public struct PaymentRequest: Encodable {
    let bookingId: Int
    let artisanId: Int?
    let refund: Bool

    public init(bookingId: Int, artisanId: Int?, refund: Bool) {
        self.bookingId = bookingId
        self.artisanId = artisanId
        self.refund = refund
    }
}