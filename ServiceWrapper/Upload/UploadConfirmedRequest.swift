//
//  UploadConfirmedRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

public struct UploadConfirmedRequest: Encodable {
    let type_id: String
    let filename: String
    
    public init(id: String, filename: String){
        self.type_id = id
        self.filename = filename
    }
}
