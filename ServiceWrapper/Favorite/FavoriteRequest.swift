//
//  FavoriteRequest.swift
//  ServiceWrapper
//
//  Created by Reyhan Rifqi Azzami on 05/04/22.
//  Copyright © 2022 PT. Perintis Teknologi Indonesia. All rights reserved.
//

public struct FavoriteRequest {
    public enum Action {
        case add
        case remove
    }
    
    public let id: Int
    public let action: Action
    
    public init(id: Int, action: Action?) {
        self.id = id
        self.action = action ?? .add
    }
}
