//
//  UploadConfirmedRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

public struct UploadConfirmedRequest: Encodable {
    let id: Int?
    let temporaryObjectName: String
    
    public init(id: Int?, temporaryObjectName: String){
        self.id = id
        self.temporaryObjectName = temporaryObjectName
    }
}
