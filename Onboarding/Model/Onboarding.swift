//
//  Onboarding.swift
//  Onboarding
//
//  Created by Fandy Gotama on 08/11/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import UIKit

public struct Onboarding {
    let image: UIImage
    let title: String
    let subtitle: String
     
    public init(image: UIImage, title: String, subtitle: String) {
        self.image = image
        self.title = title
        self.subtitle = subtitle
    }
}
