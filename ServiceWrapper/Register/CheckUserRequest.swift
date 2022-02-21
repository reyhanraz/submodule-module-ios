//
//  CheckUserRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 17/02/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

public struct CheckUserRequest: Encodable {
    public enum FindType: String{
        case email
        case phoneNumber
    }

    let identifier: String
    let type: String
    let find_type: String
    
    public init(identifier: String, type: String, findType: CheckUserRequest.FindType){
        self.identifier = identifier
        self.type = type
        self.find_type = findType.rawValue
    }
}
