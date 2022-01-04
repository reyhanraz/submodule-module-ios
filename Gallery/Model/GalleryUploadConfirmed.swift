//
//  GalleryUploadConfirmed.swift
//  Gallery
//
//  Created by Fandy Gotama on 20/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import Platform

public struct GalleryUploadConfirmed: Codable, ResponseType {
    public let status: Status.Detail
    public let data: Data?
    public let errors: [DataError]?
    
    public struct Data: Codable {
        public let galleryItem: Gallery
    }
}

