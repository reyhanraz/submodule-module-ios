//
//  UploadMediaViewModelType.swift
//  Upload
//
//  Created by Fandy Gotama on 04/07/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxCocoa
import RxSwift
import Platform
import Common

public protocol UploadMediaViewModelType {
    associatedtype Request
    associatedtype Response
    
    // Inputs
    func upload(request: Request)
    
    // Outputs
    var loading: Driver<(Request, Bool)> { get }
    var upload: Driver<Void> { get }
    var success: Driver<(Request, Response)> { get }
    var failed: Driver<(Request, Status.Detail)> { get }
    var exception: Driver<(Request, Error)> { get }
    var unauthorized: Driver<Unauthorized> { get }
}
