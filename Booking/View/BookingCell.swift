//
//  BookingCell.swift
//  Booking
//
//  Created by Fandy Gotama on 31/08/19.
//  Copyright © 2019 Adrena Teknologi Indonesia. All rights reserved.
//

import CommonUI
import Platform

public class BookingCell: BaseCollectionViewCell {
    private let _avatarSize: CGFloat = 40
    
    public let bookingView: BookingView = {
        let v = BookingView()

        v.isSkeletonable = true
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    public func setBooking(booking: Booking, kind: NewProfile.Kind) {
        bookingView.setBooking(booking: booking, kind: kind)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:)")
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        isSkeletonable = true
        
        contentView.addSubview(bookingView)
    
        NSLayoutConstraint.activate([
            bookingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            bookingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            bookingView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bookingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
