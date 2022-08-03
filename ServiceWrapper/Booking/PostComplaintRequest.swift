//
//  PostComplaintRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 15/07/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

import Foundation
public struct PostComplaintRequest: Encodable {
    public let bookingId: Int
    public let complaint: String
    
    public init(bookingId: Int, complaint: String){
        self.bookingId = bookingId
        self.complaint = complaint
    }
}
