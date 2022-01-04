//
//  FavoriteRequest.swift
//  CustomizeRequest
//
//  Created by Fandy Gotama on 03/09/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
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
