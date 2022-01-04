//
// Created by Fandy Gotama on 2019-07-27.
// Copyright (c) 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct NewsDetail: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let news: News
        
        enum CodingKeys: String, CodingKey {
            case news = "news"
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case data
        case errors
    }
}
