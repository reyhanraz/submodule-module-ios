//
//  BookingEventDetailViewModelType.swift
//  Booking
//
//  Created by Fandy Gotama on 29/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import RxSwift
import RxCocoa
import Platform
import Common

public protocol BookingEventDetailViewModelOutput {
    
    var validatedName: Driver<ValidationResult> { get }
    var validatedDate: Driver<ValidationResult> { get }
    var validatedAvailability: Driver<ValidationResult> { get }
    
    var eventDate: Driver<String> { get }
    var eventDetail: Driver<(String, Date)> { get }
    var nextEnabled: Driver<Bool> { get }
}

public protocol BookingEventDetailViewModelType {
    var outputs: BookingEventDetailViewModelOutput { get }
}

